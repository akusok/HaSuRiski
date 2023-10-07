//
//  ELM.swift
//  test-ELM
//
//  Created by Anton Akusok on 29/07/2018.
//  Copyright © 2018 Anton Akusok. All rights reserved.
//

import Foundation
import MetalPerformanceShaders


class ELM {
    var c: Int? = nil
    let bK: Int
    let bL: Int
    let alpha: Float
    var W: [MPSMatrix]
    let bias: [MPSVector]
    var L: [[MPSMatrix?]]
    var B: [MPSMatrix?]
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    
    
    init?(device: MTLDevice, bK: Int, bL: Int, alpha: Float, W: [URL], bias: [URL]) {
        if bK < 1 || bL < 1 { print("bK and bL must be positive."); return nil }
        if alpha < 0 { print("Alpha must be positive."); return nil }
        if W.count != bK { print("Wrong length of W."); return nil }
        if bias.count != bK { print("Wrong length of bias."); return nil }
        
        self.bK = bK
        self.bL = bL
        self.alpha = alpha
        
        self.W = W.map { loadFromNpy(contentsOf: $0, device: device) }
        self.bias = bias.map { loadFromNpy(contentsOf: $0, device: device) }
        
        self.device = device
        if let commandQueue = device.makeCommandQueue() {
            self.commandQueue = commandQueue
        } else {
            print("Cannot create command queue.")
            return nil
        }
        
        B = Array(repeating: nil, count: bK)
        L = Array(repeating: Array(repeating: nil, count: bK), count: bK)
    }

    func _reset(targets: Int) {
        c = targets
        for row in 0 ..< bK {
            B[row] = MPSZeros(rows: bL, columns: targets, device: device)
            L[row][row] = MPSEye(bL, alpha: alpha, device: device)
            for col in 0 ..< row {
                L[row][col] = MPSZeros(bL, device: device)
            }
        }
    }
    
    func fit(X: MPSMatrix, Y: MPSMatrix) {
        self._reset(targets: Y.columns)

        let t0 = CFAbsoluteTimeGetCurrent()
            _ = _batch_update(X: X, Y: Y)
        let t1 = CFAbsoluteTimeGetCurrent() - t0
        print("part 1", t1)
        
        let t2 = CFAbsoluteTimeGetCurrent()
            self._solve()
        let t3 = CFAbsoluteTimeGetCurrent() - t2
        print("part 2", t3)
    }
    
    func predict(X: MPSMatrix) -> MPSMatrix? {
        guard c != nil else { print("Error: un-initialized ELM encountered in prediction."); return nil }
        guard B[0] != nil else { print("Error: non-solved ELM encountered in prediction."); return nil }
        
        // prepare data storage
        let H = Array(0 ..< bK).map { _ in MPSZeros(rows: X.rows, columns: bL, device: device) }
        let Yh = MPSZeros(rows: X.rows, columns: c!, device: device)
        
        // prepare kernels
        let matMulXW = MPSMatrixMultiplication(device: device, resultRows: X.rows, resultColumns: bL, interiorColumns: X.columns)
        let matBiasTanh = MPSMatrixNeuron(device: device)
        matBiasTanh.setNeuronType(.tanH, parameterA: 1.0, parameterB: 1.0, parameterC: 0.0)
        let matMulHB = MPSMatrixMultiplication(device: device, transposeLeft: false, transposeRight: false, resultRows: X.rows, resultColumns: c!, interiorColumns: bL, alpha: 1.0, beta: 1.0)
        
        var cbuf: MTLCommandBuffer!
        
        // encode and run computations
        cbuf = commandQueue.makeCommandBuffer()!
        for i in 0 ..< bK {
            matMulXW.encode(commandBuffer: cbuf, leftMatrix: X, rightMatrix: W[i], resultMatrix: H[i])
        }
        cbuf.commit()
            
        cbuf = commandQueue.makeCommandBuffer()!
        for i in 0 ..< bK {
            matBiasTanh.encode(commandBuffer: cbuf, inputMatrix: H[i], biasVector: bias[i], resultMatrix: H[i])
        }
        cbuf.commit()
        
        for i in 0 ..< bK {
            cbuf = commandQueue.makeCommandBuffer()!
            matMulHB.encode(commandBuffer: cbuf, leftMatrix: H[i], rightMatrix: B[i]!, resultMatrix: Yh)
            cbuf.commit()
        }
        
        cbuf.waitUntilCompleted()
        return Yh
    }
    
    
    func _batch_update(X: MPSMatrix, Y: MPSMatrix) -> MTLCommandBuffer? {
        // update current ELM with a portion of new data
        guard L[0][0] != nil && c != nil else { print("Error: un-initialized ELM encountered in training."); return nil }

        // prepare data storage
        let H = Array(0 ..< bK).map { _ in MPSZeros(rows: X.rows, columns: bL, device: device) }

        // prepare kernels
        let matMulXW = MPSMatrixMultiplication(device: device, resultRows: X.rows, resultColumns: bL, interiorColumns: X.columns)
        let matMulHtH = MPSMatrixMultiplication(device: device, transposeLeft: true, transposeRight: false, resultRows: bL, resultColumns: bL, interiorColumns: X.rows, alpha: 1.0, beta: 1.0)
        let matMulHtT = MPSMatrixMultiplication(device: device, transposeLeft: true, transposeRight: false, resultRows: bL, resultColumns: c!, interiorColumns: X.rows, alpha: 1.0, beta: 1.0)
        let matBiasTanh = MPSMatrixNeuron(device: device)
        matBiasTanh.setNeuronType(.tanH, parameterA: 1.0, parameterB: 1.0, parameterC: 0.0)
        
        var cbuf: MTLCommandBuffer!
        
        // encode and run computations
        for i in 0 ..< bK {
            cbuf = commandQueue.makeCommandBuffer()!
            matMulXW.encode(commandBuffer: cbuf, leftMatrix: X, rightMatrix: W[i], resultMatrix: H[i])
            cbuf.commit()
            
            cbuf = commandQueue.makeCommandBuffer()!
            matBiasTanh.encode(commandBuffer: cbuf, inputMatrix: H[i], biasVector: bias[i], resultMatrix: H[i])
            cbuf.commit()
            
            cbuf = commandQueue.makeCommandBuffer()!
            matMulHtT.encode(commandBuffer: cbuf, leftMatrix: H[i], rightMatrix: Y, resultMatrix: B[i]!)
            for j in 0 ... i {
                matMulHtH.encode(commandBuffer: cbuf, leftMatrix: H[i], rightMatrix: H[j], resultMatrix: L[i][j]!)
            }
            cbuf.commit()
        }
        return cbuf
    }
    
    func _solve() {
        // Batch Cholesky decomposition + solver
        guard L[0][0] != nil && B[0] != nil && c != nil else { print("Error: un-initialized ELM encountered in solving."); return }
        
        // setup kernels
        let runCho = MPSMatrixDecompositionCholesky(device: device, lower: true, order: bL)
        let updateL1 = MPSMatrixSolveTriangular(device: device, right: true, upper: false, transpose: true, unit: false, order: bL, numberOfRightHandSides: bL, alpha: 1.0)
        let updateL2 = MPSMatrixMultiplication(device: device, transposeLeft: false, transposeRight: true, resultRows: bL, resultColumns: bL, interiorColumns: bL, alpha: -1.0, beta: 1.0)
        var cbuf: MTLCommandBuffer!

        // batch Cholesky solver
        for i in 0 ..< bK {
            cbuf = commandQueue.makeCommandBuffer()!
            runCho.encode(commandBuffer: cbuf, sourceMatrix: L[i][i]!, resultMatrix: L[i][i]!, status: nil)
            cbuf.commit()
            
            cbuf = commandQueue.makeCommandBuffer()!
            for j in i+1 ..< bK {
                updateL1.encode(commandBuffer: cbuf, sourceMatrix: L[i][i]!, rightHandSideMatrix: L[j][i]!, solutionMatrix: L[j][i]!)
            }
            cbuf.commit()
            
            cbuf = commandQueue.makeCommandBuffer()!
            for j in i+1 ..< bK {
                for k in j ..< bK {
                    updateL2.encode(commandBuffer: cbuf, leftMatrix: L[k][i]!, rightMatrix: L[j][i]!, resultMatrix: L[k][j]!)
                }
            }
            cbuf.commit()
        }
        
        // setup kernels
        let solveTri1 = MPSMatrixSolveTriangular(device: device, right: false, upper: false, transpose: false, unit: false, order: bL, numberOfRightHandSides: c!, alpha: 1.0)
        let solveTri2 = MPSMatrixSolveTriangular(device: device, right: false, upper: false, transpose: true, unit: false, order: bL, numberOfRightHandSides: c!, alpha: 1.0)
        let updateT = MPSMatrixMultiplication(device: device, transposeLeft: false, transposeRight: false, resultRows: bL, resultColumns: c!, interiorColumns: bL, alpha: -1.0, beta: 1.0)
        let updateT2 = MPSMatrixMultiplication(device: device, transposeLeft: true, transposeRight: false, resultRows: bL, resultColumns: c!, interiorColumns: bL, alpha: -1.0, beta: 1.0)
        
        // forward substitution
        for i in 0 ..< bK {
            cbuf = commandQueue.makeCommandBuffer()!
            solveTri1.encode(commandBuffer: cbuf, sourceMatrix: L[i][i]!, rightHandSideMatrix: B[i]!, solutionMatrix: B[i]!)
            cbuf.commit()
            
            cbuf = commandQueue.makeCommandBuffer()!
            for j in i+1 ..< bK {
                updateT.encode(commandBuffer: cbuf, leftMatrix: L[j][i]!, rightMatrix: B[i]!, resultMatrix: B[j]!)
            }
            cbuf.commit()
        }
        
        // backward substitution
        for i in (0 ..< bK).reversed() {
            cbuf = commandQueue.makeCommandBuffer()!
            solveTri2.encode(commandBuffer: cbuf, sourceMatrix: L[i][i]!, rightHandSideMatrix: B[i]!, solutionMatrix: B[i]!)
            cbuf.commit()
            
            cbuf = commandQueue.makeCommandBuffer()!
            for j in 0 ..< i {
                updateT2.encode(commandBuffer: cbuf, leftMatrix: L[i][j]!, rightMatrix: B[i]!, resultMatrix: B[j]!)
            }
            cbuf.commit()
        }
        
        cbuf.waitUntilCompleted()
        
        // clear memory
        for i in 0 ..< bK {
            for j in 0 ..< bK {
                L[i][j] = nil
            }
        }
    }
}

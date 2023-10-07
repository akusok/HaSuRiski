//
//  ELMModel.swift
//  MapKitTest
//
//  Created by Anton on 4.10.2023.
//

import SwiftUI
import MetalPerformanceShaders


class ELMModel: ObservableObject {

    @Binding var locations: [Location]
    var model: ELM?
    let device = MTLCreateSystemDefaultDevice()!
    let bK = 1  // weight batches
    let bL = 1000

    init(locations: Binding<[Location]>) {
        self._locations = locations
    }
    
    static func buildELM(locations: Binding<[Location]>) -> ELMModel {
        let mainBundle = Bundle.main
        let elm = ELMModel(locations: locations)
        
        print("Data file:")
        let fileX = mainBundle.url(forResource: "X", withExtension: "npy")!
        let fileY = mainBundle.url(forResource: "Y", withExtension: "npy")!
        let fileW = mainBundle.url(forResource: "W_\(elm.bL)", withExtension: "npy")!
        let fileBias = mainBundle.url(forResource: "bias_\(elm.bL)", withExtension: "npy")!

        let X: MPSMatrix = loadFromNpy(contentsOf: fileX, device: elm.device)
        let Y: MPSMatrix = loadFromNpy(contentsOf: fileY, device: elm.device)
        
        let t0 = CFAbsoluteTimeGetCurrent()
        elm.model = ELM(device: elm.device, bK: elm.bK, bL: elm.bL, alpha: 1E2, W: [fileW], bias: [fileBias])
        elm.model!.fit(X: X, Y: Y)
        let t = CFAbsoluteTimeGetCurrent() - t0
        print(String(format: "Training time: %.3f", t))
        return elm
    }
    
    func train() {
        let mainBundle = Bundle.main
        let fileX = mainBundle.url(forResource: "X", withExtension: "npy")!
        let fileY = mainBundle.url(forResource: "Y", withExtension: "npy")!
        let fileW = mainBundle.url(forResource: "W_\(bL)", withExtension: "npy")!
        let fileBias = mainBundle.url(forResource: "bias_\(bL)", withExtension: "npy")!

        let npX = try! Npy(contentsOf: fileX)
        let npY = try! Npy(contentsOf: fileY)
        let aX = Array(npX.elementsData)
        let aY = Array(npY.elementsData)
        
        print(aX.count)
//
//        let X: MPSMatrix = loadFromNpy(contentsOf: fileX, device: device)
//        let Y: MPSMatrix = loadFromNpy(contentsOf: fileY, device: device)
//
//        
//        let rows = npy.shape[0]
//        let columns = npy.shape[1]
//        let buffer = device.makeBuffer(bytes: Array(npy.elementsData), length: rows * columns * fp32stride, options: [])!
//        let descr = MPSMatrixDescriptor(rows: rows, columns: columns, rowBytes: columns * fp32stride, dataType: .float32)
//        return MPSMatrix(buffer: buffer, descriptor: descr)
//
        
        
    }
    
    func predict(data: Data) -> MPSMatrix? {
        guard let Xs: MPSMatrix = loadFromNpy(data: data, device: self.device) else { return nil }        
        return model!.predict(X: Xs)
    }
    
}

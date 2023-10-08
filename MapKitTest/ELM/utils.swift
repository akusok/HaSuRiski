//
//  utils.swift
//  desktop-ELM
//
//  Created by Anton Akusok on 29/07/2018.
//  Copyright © 2018 Anton Akusok. All rights reserved.
//

import Foundation
import MetalPerformanceShaders

let fp32stride = MemoryLayout<Float>.stride

func loadFromNpy(contentsOf url: URL, device: MTLDevice) -> MPSMatrix {
    let npy = try! Npy(contentsOf: url)
    let rows = npy.shape[0]
    let columns = npy.shape[1]
    let buffer = device.makeBuffer(bytes: Array(npy.elementsData), length: rows * columns * fp32stride, options: [])!
    let descr = MPSMatrixDescriptor(rows: rows, columns: columns, rowBytes: columns * fp32stride, dataType: .float32)
    return MPSMatrix(buffer: buffer, descriptor: descr)
}

func loadFromNpy(data: Data, device: MTLDevice) -> MPSMatrix? {
    guard let npy = try? Npy(data: data) else {
        return nil
    }
    let rows = npy.shape[0]
    let columns = npy.shape[1]
    
    let buffer = device.makeBuffer(bytes: Array(npy.elementsData), length: rows * columns * fp32stride, options: [])!
    let descr = MPSMatrixDescriptor(rows: rows, columns: columns, rowBytes: columns * fp32stride, dataType: .float32)
    return MPSMatrix(buffer: buffer, descriptor: descr)
}

func loadFromNpy(contentsOf url: URL, device: MTLDevice) -> MPSVector {
    let npy = try! Npy(contentsOf: url)
    let elements = npy.shape[0]
    let buffer = device.makeBuffer(bytes: Array(npy.elementsData), length: elements * fp32stride, options: [])!
    let descr = MPSVectorDescriptor(length: elements, dataType: .float32)
    return MPSVector(buffer: buffer, descriptor: descr)
}

func loadFromNpy(data: Data, device: MTLDevice) -> MPSVector {
    let npy = try! Npy(data: data)
    let elements = npy.shape[0]
    let buffer = device.makeBuffer(bytes: Array(npy.elementsData), length: elements * fp32stride, options: [])!
    let descr = MPSVectorDescriptor(length: elements, dataType: .float32)
    return MPSVector(buffer: buffer, descriptor: descr)
}

func MPSZeros(_ n: Int, device: MTLDevice) -> MPSMatrix {
    let descr = MPSMatrixDescriptor(rows: n, columns: n, rowBytes: n * fp32stride, dataType: .float32)
    let buffer = device.makeBuffer(length: n * n * fp32stride, options: [])!
    return MPSMatrix(buffer: buffer, descriptor: descr)
}

func MPSZeros(rows: Int, columns: Int, device: MTLDevice) -> MPSMatrix {
    let descr = MPSMatrixDescriptor(rows: rows, columns: columns, rowBytes: columns * fp32stride, dataType: .float32)
    let buffer = device.makeBuffer(length: rows * columns * fp32stride, options: [])!
    return MPSMatrix(buffer: buffer, descriptor: descr)
}

func MPSOnes(rows: Int, columns: Int, device: MTLDevice) -> MPSMatrix {
    let descr = MPSMatrixDescriptor(rows: rows, columns: columns, rowBytes: columns * fp32stride, dataType: .float32)
    let buffer = device.makeBuffer(length: rows * columns * fp32stride, options: [])!
    return MPSMatrix(buffer: buffer, descriptor: descr)
}

func MPSEye(_ n: Int, alpha: Float, device: MTLDevice) -> MPSMatrix {
    let ptr = UnsafeMutablePointer<Float>.allocate(capacity: n * n)
    ptr.initialize(repeating: 0.0, count: n*n)
    for i in stride(from: 0, to: n*n, by: n+1) { ptr[i] = alpha }  // fill diagonal
    
    let descr = MPSMatrixDescriptor(rows: n, columns: n, rowBytes: n * fp32stride, dataType: .float32)
    let buffer = device.makeBuffer(bytes: ptr, length: n * n * fp32stride, options: [])!
    ptr.deallocate()
    return MPSMatrix(buffer: buffer, descriptor: descr)
}

func npyToArray(_ npy: Npy) -> Array<Float32> {
    let n_elements = npy.shape.reduce(1) { $0 * $1 }
    var arr = Array<Float32>(repeating: 0, count: n_elements)
    _ = arr.withUnsafeMutableBytes { npy.elementsData.copyBytes(to: $0) }
    return arr
}

//func arrayData(_ arr: Array<Float32>) -> Data {
//    return Data(buffer: UnsafeBufferPointer<Float32>(start: arr, count: arr.count))
//}

func loadFromArray(arr: Array<Float32>, rows: Int, columns: Int, device: MTLDevice) -> MPSMatrix? {
    let buffer = device.makeBuffer(bytes: arr, length: rows * columns * fp32stride, options: [])!
    let descr = MPSMatrixDescriptor(rows: rows, columns: columns, rowBytes: columns * fp32stride, dataType: .float32)
    return MPSMatrix(buffer: buffer, descriptor: descr)
}

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
    let sample_weight: Float32 = 10.0

    init(locations: Binding<[Location]>) {
        self._locations = locations
    }
    
    static func buildELM(locations: Binding<[Location]>) -> ELMModel {
        let mainBundle = Bundle.main
        let elm = ELMModel(locations: locations)
        
        print("Data file:")
        let fileW = mainBundle.url(forResource: "W_\(elm.bL)", withExtension: "npy")!
        let fileBias = mainBundle.url(forResource: "bias_\(elm.bL)", withExtension: "npy")!

        elm.model = ELM(device: elm.device, bK: elm.bK, bL: elm.bL, alpha: 1E2, W: [fileW], bias: [fileBias])
        elm.train()
        return elm
    }
    
    func train() {
        let mainBundle = Bundle.main
        let fileX = mainBundle.url(forResource: "X", withExtension: "npy")!
        let fileY = mainBundle.url(forResource: "Y", withExtension: "npy")!
        let npX = try! Npy(contentsOf: fileX)
        let npY = try! Npy(contentsOf: fileY)
        
        var aY = npyToArray(npY)
        var aX = npyToArray(npX)
        for location in locations {
            aY.append(contentsOf: location.y.map { $0 * sample_weight })
            aX.append(contentsOf: location.x)
        }
        
        let rows = npX.shape[0] + locations.count
        let X: MPSMatrix = loadFromArray(arr: aX, rows: rows, columns: npX.shape[1], device: self.device)!
        let Y: MPSMatrix = loadFromArray(arr: aY, rows: rows, columns: npY.shape[1], device: self.device)!
        
        let t0 = CFAbsoluteTimeGetCurrent()
        self.model!.fit(X: X, Y: Y)
        let t = CFAbsoluteTimeGetCurrent() - t0
        print(String(format: "Training time: %.3f", t))
    }
    
    func predict(data: Data) -> MPSMatrix? {
        guard let Xs: MPSMatrix = loadFromNpy(data: data, device: self.device) else { return nil }        
        return model!.predict(X: Xs)
    }
    
}

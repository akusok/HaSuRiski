//
//  ELMModel.swift
//  MapKitTest
//
//  Created by Anton on 4.10.2023.
//

import SwiftUI
import MetalPerformanceShaders


class ELMModel: ObservableObject {

    let device = MTLCreateSystemDefaultDevice()!
    var model: ELM?
    
    static func buildELM() -> ELMModel {
        let mainBundle = Bundle.main
        let elm = ELMModel()
        
        let bK = 1  // weight batches
        let bL = 1000
        
        print("Data file:")
        let fileX = mainBundle.url(forResource: "X", withExtension: "npy")!
        let fileY = mainBundle.url(forResource: "Y", withExtension: "npy")!
        let fileW = mainBundle.url(forResource: "W_\(bL)", withExtension: "npy")!
        let fileBias = mainBundle.url(forResource: "bias_\(bL)", withExtension: "npy")!

        let X: MPSMatrix = loadFromNpy(contentsOf: fileX, device: elm.device)
        let Y: MPSMatrix = loadFromNpy(contentsOf: fileY, device: elm.device)
        
        let t0 = CFAbsoluteTimeGetCurrent()
        elm.model = ELM(device: elm.device, bK: bK, bL: bL, alpha: 1E2, W: [fileW], bias: [fileBias])
        elm.model!.fit(X: X, Y: Y)
        let t = CFAbsoluteTimeGetCurrent() - t0
        print(String(format: "Training time: %.3f", t))
        return elm
    }
    
    func predict(data: Data) -> MPSMatrix? {
        guard let Xs: MPSMatrix = loadFromNpy(data: data, device: self.device) else { return nil }        
        return model!.predict(X: Xs)
    }
    
}

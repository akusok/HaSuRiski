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
        
        // use uploaded files
//        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//        let allFiles = try! FileManager.default.contentsOfDirectory(at: docDir, includingPropertiesForKeys: nil)
//        let myFiles = Dictionary(uniqueKeysWithValues: allFiles.map { ($0.lastPathComponent, $0) })
        
        let bK = 1  // weight batches
        let bL = 100
        
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
    
    func getRemoteImage(_ z: Int, _ x: Int, _ y: Int) async {
        
        let url = URL(string: "http://akusok.asuscomm.com:9000/elevation/combined_data/\(z)/\(x)/\(y).npy")!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("bad return code")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data {
                DispatchQueue.main.async { self.predictWithModel(data: data) }
            }
        }
        task.resume()
    }
    
    func predictWithModel(data: Data) {
        
        guard let model=self.model else {
            print("Model not trained!")
            return
        }

        let t0 = CFAbsoluteTimeGetCurrent()
        let Xs: MPSMatrix = loadFromNpy(data: data, device: self.device)!
        _ = model.predict(X: Xs)
        let t2 = CFAbsoluteTimeGetCurrent() - t0
        
        print(String(format: "Predict time: %.0f ms", t2*1000))
    }
    
    func predict(data: Data) -> MPSMatrix? {
        
        guard let model=self.model else {
            print("Model not trained!")
            return nil
        }
        
        guard let Xs: MPSMatrix = loadFromNpy(data: data, device: self.device) else {
            print("Cannot load Xs")
            return nil
        }
        
        return model.predict(X: Xs)
    }
    
}

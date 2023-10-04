//
//  ELMModel.swift
//  MapKitTest
//
//  Created by Anton on 4.10.2023.
//

import SwiftUI
import MetalPerformanceShaders


class ELMModel {

    let device = MTLCreateSystemDefaultDevice()!
    var model: ELM?
    
    func buildELM() {
        let mainBundle = Bundle.main
        
        // use uploaded files
        let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let allFiles = try! FileManager.default.contentsOfDirectory(at: docDir, includingPropertiesForKeys: nil)
        let myFiles = Dictionary(uniqueKeysWithValues: allFiles.map { ($0.lastPathComponent, $0) })
        
        let bK = 1  // weight batches
        let bL = 150
        
        print("Data file:")
        let fileX = mainBundle.url(forResource: "hX", withExtension: "npy")!
        let fileY = mainBundle.url(forResource: "hY", withExtension: "npy")!
        let fileW = mainBundle.url(forResource: "hW_150", withExtension: "npy")!
        let fileBias = mainBundle.url(forResource: "hbias_150", withExtension: "npy")!

        let X: MPSMatrix = loadFromNpy(contentsOf: fileX, device: self.device)
        let Y: MPSMatrix = loadFromNpy(contentsOf: fileY, device: self.device)
        
        let t0 = CFAbsoluteTimeGetCurrent()
        self.model = ELM(device: self.device, bK: bK, bL: bL, alpha: 1E1, W: [fileW], bias: [fileBias])
        self.model!.fit(X: X, Y: Y)
        let t = CFAbsoluteTimeGetCurrent() - t0
        print(String(format: "Training time: %.3f", t))
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
                DispatchQueue.main.async { self.predictWithModel(data: data, y: y) }
            }
        }
        task.resume()
    }
    
    func predictWithModel(data: Data, y: Int) {
        
        guard let model=self.model else {
            print("Model not trained!")
            return
        }

        let t0 = CFAbsoluteTimeGetCurrent()
        let Xs: MPSMatrix = loadFromNpy(data: data, device: self.device)
        _ = model.predict(X: Xs)
        let t2 = CFAbsoluteTimeGetCurrent() - t0
        
        print(String(format: "Predict time of y=\(y): %.0f ms", t2*1000))
    }
    
    
}

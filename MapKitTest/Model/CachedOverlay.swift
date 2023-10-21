//
//  CachedTilesModel.swift
//  MapKitTest
//
//  Created by Anton Akusok on 7.9.2023.
//
//

import SwiftUI
import Cache
import MapKit
import MetalPerformanceShaders


class CachedTileOverlay: MKTileOverlay {
    internal var enableCache = true

    private let operationQueue = OperationQueue()
    private let session = URLSession.shared
    private let device: MTLDevice
    private let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)


    @Published var selectedLayer: Layer = .standard
    @Published var elm: ELMModel?
    
    private let cache = try! Storage<String, Data>(
        diskConfig: DiskConfig(name: "TileCache"),
        memoryConfig: MemoryConfig(expiry: .never, countLimit: 5_000, totalCostLimit: 100_000),
        transformer: TransformerFactory.forData()
    )
    private let subdomains = ["a", "b", "c"]

    override init(urlTemplate URLTemplate: String?) {
        device = MTLCreateSystemDefaultDevice()!
        super.init(urlTemplate: URLTemplate)
        UIGraphicsGetCurrentContext()?.interpolationQuality = .high
        try? self.cache.removeExpiredObjects()
        self.clearCache()
    }

    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        
        let subsample = 1  // subsampled images
        let n = (256/subsample)*(256/subsample)

        if self.selectedLayer == .hasuriski {
            // save data tile
            let dataCacheKey = "\(self.urlTemplate!)-\(path.x)-\(path.y)-\(path.z)-\(path.contentScaleFactor)-data"
            self.cache.async.object(forKey: dataCacheKey) { val in
                switch val {
                case .success(let imgData):
                    result(imgData, nil)
                    
                case .failure:
                    
                    // create basic image array
                    var Yh_arr = Array<UInt8>(repeating: 255, count: n*4)
                    
                    // load local file
                    let url = URL(string: "\(self.docDir)\(path.z)/\(path.x)/\(path.y).npy")!
                    var loadSuccess = false
                    
                    if let combinedData = try? Data(contentsOf: url) {
                        if let Yh = self.elm!.predict(data: combinedData) {
                            loadSuccess = true
                            let res = Yh.data.contents().bindMemory(to: Float.self, capacity: n)
                            for i in 0 ..< n {
                                let val = (0.7 - res[i])*4  // "colormap" scaling
                                let ival = UInt8(min(max(val, 0), 1) * 255)
                                Yh_arr[i*4] = ival
                                Yh_arr[i*4 + 1] = ival
                                Yh_arr[i*4 + 2] = ival
                                Yh_arr[i*4 + 3] = 255 - ival
                            }
                        }
                        
                        // use imageUtil with 4-channel array
                        // blur adds boundaries between images
                        let img = UIImage(Yh_arr, width: 256/subsample, height: 256/subsample)
                        let imgData = img.pngData()!
                        if loadSuccess {
                            self.cache.async.setObject(imgData, forKey: dataCacheKey, completion: { _ in  })
                        }
                        
//                        print("Getting data for: \(url)")
                        result(imgData, nil)
                    } else {
//                        print("Error loading: \(url)")
                    }
                }
            }
            
        } else if self.selectedLayer == .antonEnnako {
            // local cached images
            let dataDir = "predict_terrain"
            let url = URL(string: "\(self.docDir)\(dataDir)/\(path.z)/\(path.x)/\(path.y).png")!
            if let imageData = try? Data(contentsOf: url) {
                let img = UIImage(data: imageData)!
                result(img.pngData()!, nil)
            } else {
//                print("error loading \(url)")
            }
            
        } else if self.selectedLayer == .gtkEnnako {
            // local cached images
            let dataDir = "hasuriski_ennako"
            let url = URL(string: "\(self.docDir)\(dataDir)/\(path.z)/\(path.x)/\(path.y).png")!
            if let imageData = try? Data(contentsOf: url) {
                let img = UIImage(data: imageData)!
                result(img.pngData()!, nil)
            } else {
//                print("error loading \(url)")
            }

        } else {
            // normal cached image
            let cacheKey = "\(self.urlTemplate!)-\(path.x)-\(path.y)-\(path.z)-\(path.contentScaleFactor)"
            self.cache.async.object(forKey: cacheKey) { val in
                switch val {
                case .success(let data):
                    result(data, nil)
                case .failure:
                    let url = self.url(forTilePath: path)
                    let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 3)
                    
                    self.session.dataTask(with: request) { data, _, error in
                        if let data = data {
                            self.cache.async.setObject(data, forKey: cacheKey, completion: { _ in  })
                            result(data, error)
                        }
                    }.resume()
                }
            }
        }
    }

    internal func clearCache() {
        try? cache.removeAll()
        print("Tile Cache cleared!")
    }

    override func url(forTilePath path: MKTileOverlayPath) -> URL {
        var urlString = urlTemplate?.replacingOccurrences(of: "{z}", with: String(path.z))
        urlString = urlString?.replacingOccurrences(of: "{x}", with: String(path.x))
        urlString = urlString?.replacingOccurrences(of: "{y}", with: String(path.y))
        urlString = urlString?.replacingOccurrences(of: "{s}", with: subdomains.randomElement()!)
        if path.contentScaleFactor >= 2 {
            urlString = urlString?.replacingOccurrences(of: "{csf}", with: "@2x")
        } else {
            urlString = urlString?.replacingOccurrences(of: "{csf}", with: "")
        }
        return URL(string: urlString!)!
    }
}

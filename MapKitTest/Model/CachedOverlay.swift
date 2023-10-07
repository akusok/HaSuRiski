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

    @Published var isGrayscale: Bool = false
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
        
        if self.selectedLayer == .hasuriski {
            // save data tile
            let dataCacheKey = "\(self.urlTemplate!)-\(path.x)-\(path.y)-\(path.z)-\(path.contentScaleFactor)-data"
            self.cache.async.object(forKey: dataCacheKey) { val in
                switch val {
                case .success(let imgData):
                    print("Loading cached data")
                    result(imgData, nil)
                    
                case .failure:
                    print("Loading HaSuRiski map")
                    // create basic image array
                    let reduce = 4
                    let dataDir = "combined_data_4"
                    
                    let n = (256/reduce)*(256/reduce)
                    var Yh_arr = Array<UInt8>(repeating: 255, count: n*4)

                    // loading remote data, predicting, writing predictions to pixels
                    let url = URL(string: "http://akusok.asuscomm.com:9000/elevation/\(dataDir)/\(path.z)/\(path.x)/\(path.y).npy")!
                    let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 15)
                    self.session.dataTask(with: request) { data, _, error in
                        var loadSuccess = false
                        if let combinedData=data {
                            if let Yh = self.elm!.predict(data: combinedData) {
                                let res = Yh.data.contents().bindMemory(to: Float.self, capacity: n)
                                for i in 0 ..< n {
                                    let val = (0.7 - res[i])*4  // "colormap" scaling
                                    let ival = UInt8(min(max(val, 0), 1) * 255)
                                    Yh_arr[i*4] = ival
                                    Yh_arr[i*4 + 1] = ival
                                    Yh_arr[i*4 + 2] = ival
                                    Yh_arr[i*4 + 3] = 255 - ival
                                }
                                loadSuccess = true
                            }
                        }
                        
                        // use imageUtil with 4-channel array
                        // blur adds boundaries between images
                        let img = UIImage(Yh_arr, width: 256/reduce, height: 256/reduce).resize(256, 256)!  // .blur(radius: 0.5)!
                        let imgData = img.pngData()!
                        if loadSuccess {
                            self.cache.async.setObject(imgData, forKey: dataCacheKey, completion: { _ in  })
                        }

                        print("Sending data for: \(url)")
                        result(imgData, nil)
                        
                    }.resume()
                }
            }
            
        } else {
            // normal cached image
            let cacheKey = "\(self.urlTemplate!)-\(path.x)-\(path.y)-\(path.z)-\(path.contentScaleFactor)"
            self.cache.async.object(forKey: cacheKey) { val in
                switch val {
                case .success(let data):
                    result(self.scaleUp(data: data, targetHeight: self.tileSize.height), nil)
                case .failure:
                    let url = self.url(forTilePath: path)
                    let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 3)
                    
                    self.session.dataTask(with: request) { data, _, error in
                        if data != nil {
                            let upscaledData = self.scaleUp(data: data!, targetHeight: self.tileSize.height)
                            self.cache.async.setObject(upscaledData, forKey: cacheKey, completion: { _ in  })
                            result(upscaledData, error)
                        }
                    }.resume()
                }
            }
        }
    }

    private func scaleUp (data: Data, targetHeight: CGFloat) -> Data {
        if let img = Image(data: data) {
            if self.isGrayscale {
                return img.noir(device: device)!.pngData()!
            }
        }
        return data
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



// Make uiImage from data

//let width = 2
//let height = 1
//let bytesPerPixel = 4 // RGBA
//
//let content = UnsafeMutablePointer<UInt8>.allocate(capacity: width * height * bytesPerPixel)
//apply_raw_data(content) // set content to [255,0,0,0,255,0,0,0]
//
//let colorSpace = CGColorSpaceCreateDeviceRGB()
//
//guard let context = CGContext(data: content, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
//    else { return }
//    
//if let cgImage = context.makeImage() {
//    let image = UIImage(cgImage)
//    // use image here
//}

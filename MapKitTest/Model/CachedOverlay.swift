//
//  CachedTilesModel.swift
//  MapKitTest
//
//  Created by Anton Akusok on 7.9.2023.
//
//

import Cache
import MapKit
import MetalPerformanceShaders


class CachedTileOverlay: MKTileOverlay {

    internal var enableCache = true

    private let operationQueue = OperationQueue()
    private let session = URLSession.shared
    @Published var isGrayscale: Bool = false
    private let device: MTLDevice

    
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
    }

    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        let cacheKey = "\(self.urlTemplate!)-\(path.x)-\(path.y)-\(path.z)-\(path.contentScaleFactor)"
        self.cache.async.object(forKey: cacheKey) { val in
            switch val {
            case .success(let data):
                print("Cached!")
                result(self.scaleUp(data: data, targetHeight: self.tileSize.height), nil)
            case .failure:
                print("Requesting Data")
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

    private func scaleUp (data: Data, targetHeight: CGFloat) -> Data {
        if let img = Image(data: data) {
            if self.isGrayscale {
                return img.noir(device: device)!.pngData()!
            }
        }
        return data
    }
    
//    private func scaleUp (data: Data, targetHeight: CGFloat) -> Data {
//        if let img = Image(data: data) {
//            if img.size.height < targetHeight {
//                return img.resize(targetHeight, targetHeight)!.pngData()!
//            }
//        }
//        return data
//    }

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

extension UIImage {
    func resize(_ width: CGFloat, _ height: CGFloat) -> UIImage? {
        let widthRatio  = width / size.width
        let heightRatio = height / size.height
        let ratio = widthRatio > heightRatio ? heightRatio : widthRatio
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func noir(device: MTLDevice) -> UIImage? {
        
        let x = self.cgImage!
        print(x.bitsPerPixel)
        let provider = x.dataProvider
        let providerData = provider?.data!
        let dataPtr = CFDataGetBytePtr(providerData)!
        
        let N = 256*256*4
        var dataDiff: [UInt8] = Array(repeating: 0, count: N)
        for i in stride(from: 0, to: N, by: 4) { dataDiff[i] = dataPtr[i] < 200 ? 50 : 0 }
        
        
        var dataVector2: [UInt8]?
        let a, b: Int
        (dataVector2, a, b) = UIImage(cgImage: x).pixelData()
        
        print(dataVector2?.count)
        print(Array(0..<20).map { dataVector2![$0] })
        
        
        let buffer = device.makeBuffer(bytes: dataPtr, length: N, options: [])!
        let descr = MPSVectorDescriptor(length: N, dataType: .uInt8)
        let dataVector = MPSVector(buffer: buffer, descriptor: descr)
                
        let res = dataVector.data.contents().bindMemory(to: UInt8.self, capacity: N)
        let resArray = Array(0 ..< 20).map { res[$0] }
        print(resArray.map{ String($0) }.joined(separator: "\t"))
        
        let context = CIContext(options: nil)
        guard let currentFilter = CIFilter(name: "CIPhotoEffectNoir") else { return nil }
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        if let output = currentFilter.outputImage,
           let cgImage = context.createCGImage(output, from: output.extent) {
           return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }
        return nil
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

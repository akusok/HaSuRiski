//
//  utils.swift
//  MapKitTest
//
//  Created by Anton on 22.9.2023.
//

import SwiftUI
import CoreImage.CIFilterBuiltins
import MetalPerformanceShaders

extension UIImage {
    
    convenience init(_ data: [UInt8], width: Int, height: Int) {
        var ownData = Array<UInt8>(repeating: 0, count: width*height*4)
        for i in 0..<width*height*4 {
            ownData[i] = data[i]
        }
        let cgImg = ownData.withUnsafeMutableBytes { (ptr) -> CGImage in
            let ctx = CGContext(
                data: ptr.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: 4*width,
                space: CGColorSpace(name: CGColorSpace.sRGB)!,
                bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue +
                CGImageAlphaInfo.premultipliedFirst.rawValue
            )!
            return ctx.makeImage()!
        }
        self.init(cgImage: cgImg)
    }
    
    func pixelData() -> ([UInt8]?, Int, Int) {
        let size = self.size
        let dataSize = size.width * size.height * 4
        var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: &pixelData,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: 4 * Int(size.width),
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        guard let cgImage = self.cgImage else { return (nil, 0, 0) }
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        return (pixelData, Int(size.width), Int(size.height))
    }
    
    func resize(_ width: CGFloat, _ height: CGFloat) -> UIImage? {
        let widthRatio  = width / size.width
        let heightRatio = height / size.height
        let ratio = widthRatio > heightRatio ? heightRatio : widthRatio
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
//        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
//        context.interpolationQuality = CGInterpolationQuality(rawValue: 3)!
//        context.draw(self.cgImage!, in: rect, byTiling: false)
//        let newImage = UIImage(cgImage: context.makeImage()!)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func blur(radius: Float) -> UIImage? {
        let image = CIImage(image: self)
        let blurFilter = CIFilter.gaussianBlur()
        blurFilter.inputImage = image
        blurFilter.radius = radius
        guard let ciImage = blurFilter.outputImage else { return nil }
        return UIImage(ciImage: ciImage)
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

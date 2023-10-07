//
//  utils.swift
//  MapKitTest
//
//  Created by Anton on 22.9.2023.
//

import SwiftUI

extension UIImage {
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
    
//    convenience init(_ data: inout [UInt8], width: Int, height: Int) {
//        let cgImg = data.withUnsafeMutableBytes { (ptr) -> CGImage in
//            let ctx = CGContext(
//                data: ptr.baseAddress,
//                width: width,
//                height: height,
//                bitsPerComponent: 8,
//                bytesPerRow: 4*width,
//                space: CGColorSpace(name: CGColorSpace.sRGB)!,
//                bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue +
//                CGImageAlphaInfo.premultipliedFirst.rawValue
//            )!
//            return ctx.makeImage()!
//        }
//        self.init(cgImage: cgImg)
//    }
    
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
}

//
//  Location.swift
//  HaSuRiski
//
//  Created by Anton on 15.1.2023.
//

import SwiftUI
import UniformTypeIdentifiers
import MapKit

let session = URLSession.shared
let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)


func get_pixel_data(lat: Double, lon: Double, zoom: Int = 10) -> Array<Float32> {
    
    let sem = DispatchSemaphore.init(value: 0)
    
    // project pixel
    var siny = sin(lat * Double.pi / 180)
    siny = min(max(siny, -0.9999), 0.9999)
    
    let x: Double = 256.0 * (0.5 + lon / 360)
    let y: Double = 256.0 * (0.5 - log((1 + siny) / (1 - siny)) / (4 * Double.pi))
    
    let scale: Double = pow(2.0, Double(zoom))
    
    let tx = Int(x * scale / 256)
    let ty = Int(y * scale / 256)
    
    let px = Int(Float(x * scale).truncatingRemainder(dividingBy: 256).rounded(.down)) / Constants.subsample
    let py = Int(Float(y * scale).truncatingRemainder(dividingBy: 256).rounded(.down)) / Constants.subsample
    let imgSize = 256 / Constants.subsample

    // load data
    guard let url = URL(string: "\(docDir)\(zoom)/\(tx)/\(ty).npy") else {
        return Array(repeating: 0.0, count: 11)
    }
    
    let npy = try! Npy(contentsOf: url)
    let imgData = npyToArray(npy)
    let n = 11 * (px*imgSize + py)
    let result = Array(imgData[n..<n+11])
    
    return result
}


struct Location: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var name: String
    var acidSulfate: Bool
    let latitude: Double
    let longitude: Double
    var x: Array<Float>

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var color: Color {
        return acidSulfate ? .red : .green
    }
    
    static let example = Location(
        id: UUID(), name: "Helsinki", acidSulfate: false, latitude: 60.1699, longitude: 24.9384,
        x: get_pixel_data(lat: 60.1699, lon: 24.9384)
    )
    
    static func ==(lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
    
    var y: Array<Float32> {
        return Array<Float32>(repeating: acidSulfate ? 1.0 : -1.0, count: 1)
    }
    
}

struct LocationDoc: FileDocument {

    static var readableContentTypes: [UTType] { [.json] }

    private var content: [Location]
    init(content: [Location]) {
        self.content = content
    }

    init(configuration: ReadConfiguration) throws {
        // read content from configuration.file
        self.content = []
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        do {
            let json = try String(data: JSONEncoder().encode(content), encoding: String.Encoding.utf8)
            let data = json?.data(using: .utf8) ?? Data()
            return FileWrapper(regularFileWithContents: data)
        } catch {
            return FileWrapper(regularFileWithContents: Data())
        }
    }
}


class LocAnnotation: MKPointAnnotation {
  
  var poi: Location
  
  var markerColor: UIColor {
      poi.acidSulfate ? .red : .green
  }
  
  var markerGlyph: UIImage {
      UIImage(systemName: "star.circle")!
  }
  
  init(poi: Location) {
    self.poi = poi
    super.init()
    self.coordinate = CLLocationCoordinate2D(latitude: poi.latitude, longitude: poi.longitude)
  }
  
}

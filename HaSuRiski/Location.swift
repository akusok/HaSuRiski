//
//  Location.swift
//  HaSuRiski
//
//  Created by Anton on 15.1.2023.
//

import SwiftUI
import UniformTypeIdentifiers
import MapKit

struct Location: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var acidity: Double
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    static let example = Location(id: UUID(), name: "Helsinki", acidity: 7.0, latitude: 60.1699, longitude: 24.9384)
    
    static func ==(lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
}

struct LocationDoc: FileDocument {

    static var readableContentTypes: [UTType] { [.plainText] }

    private var content: [Location]
    init(content: [Location]) {
        self.content = content
    }

    init(configuration: ReadConfiguration) throws {
        // read content from configuration.file
        self.content = []
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let header = "Name,Acidity,Latitude,Longitude,ID\n"
        let text = header + content.reduce("") {
            $0 + "\($1.name),\($1.acidity),\($1.latitude),\($1.longitude),\($1.id)\n"
        }
        return FileWrapper(regularFileWithContents: text.data(using: .utf8) ?? Data())
    }
}

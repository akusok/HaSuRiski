//
//  Location.swift
//  HaSuRiski
//
//  Created by Anton on 15.1.2023.
//

import SwiftUI
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

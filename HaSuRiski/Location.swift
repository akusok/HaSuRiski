//
//  Location.swift
//  HaSuRiski
//
//  Created by Anton on 15.1.2023.
//

import SwiftUI

struct Location: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var acidity: Double
    let latitude: Double
    let longitude: Double
}

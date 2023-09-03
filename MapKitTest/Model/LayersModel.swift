//
//  InfoView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 11/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI

enum Layer: String, CaseIterable, Equatable, Identifiable {
    
    case standard = "<default>"
    case satellite = "<satellite>"
    case flyover = "<flyover>"
    case ign = "IGN"
    case ign25 = "ign25"
    case openStreetMap = "OSM"
    case openTopoMap = "Open Topo Map"
    case swissTopo = "Swiss Topo map"

    var localized: LocalizedStringKey { LocalizedStringKey(rawValue) }
    
    /// Only layers we can actually download (MKTileOverlay),  (Maps currentType standard, hybrid, flyover are not  overlays)
    static var onlyOverlaysLayers: [Layer] { [.ign25, .openTopoMap, .ign, .openStreetMap, .swissTopo] }
    
    var id: Self { self }
    
}

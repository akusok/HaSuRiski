//
//  InfoView.swift
//  Rando
//
//  Created by Mathieu Vandeginste on 11/05/2020.
//  Copyright © 2020 Mathieu Vandeginste. All rights reserved.
//

import SwiftUI
import MapKit

enum Layer: String, CaseIterable, Equatable, Identifiable {
    
    case standard = "<default>"
    case flyover = "<flyover>"
    case openTopoMap = "Open Topo"
    case gtkEnnako = "GTK"
    case antonEnnako = "HaSuRiski"
    case hasuriski = "HaSuRiski Live"

    var localized: LocalizedStringKey { LocalizedStringKey(rawValue) }
    
    var id: Self { self }
}

let mapPaths: [Layer: String] = [
    .openTopoMap: "https://b.tile.opentopomap.org/{z}/{x}/{y}.png",
    .hasuriski: "http://akusok.asuscomm.com:9000/elevation/predict_terrain/{z}/{x}/{y}.png",
    .antonEnnako: "http://akusok.asuscomm.com:9000/elevation/predict_terrain/{z}/{x}/{y}.png",
    .gtkEnnako: "http://akusok.asuscomm.com:9000/elevation/hasuriski_ennako/{z}/{x}/{y}.png",
]

let mapTileOverlays: [Layer: MKTileOverlay] = [
    .openTopoMap: MKTileOverlay(urlTemplate:"https://b.tile.opentopomap.org/{z}/{x}/{y}.png"),
    .hasuriski: MKTileOverlay(urlTemplate:"http://akusok.asuscomm.com:9000/elevation/predict_terrain/{z}/{x}/{y}.png"),
    .antonEnnako: MKTileOverlay(urlTemplate:"http://akusok.asuscomm.com:9000/elevation/predict_terrain/{z}/{x}/{y}.png"),
    .gtkEnnako: MKTileOverlay(urlTemplate:"http://akusok.asuscomm.com:9000/elevation/hasuriski_ennako/{z}/{x}/{y}.png"),
]


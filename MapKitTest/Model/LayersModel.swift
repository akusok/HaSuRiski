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
    case satellite = "<satellite>"
    case flyover = "<flyover>"
    case ign = "IGN"
    case ign25 = "ign25"
    case openStreetMap = "OSM"
    case openTopoMap = "Open Topo Map"
    case swissTopo = "Swiss Topo map"
    case hasuriski = "<my> HaSuRiski"
    case gtkEnnako = "<GTK> Ennako"

    var localized: LocalizedStringKey { LocalizedStringKey(rawValue) }
    
    /// Only layers we can actually download (MKTileOverlay),  (Maps currentType standard, hybrid, flyover are not  overlays)
    static var onlyOverlaysLayers: [Layer] { [.ign25, .openTopoMap, .ign, .openStreetMap, .swissTopo] }
    
    var id: Self { self }
    
}

// example URL:  http://server/path?x={x}&y={y}&z={z}&scale={scale}.

let mapPaths: [Layer: String] = [
    .ign: "https://wxs.ign.fr/pratique/geoportail/wmts?layer=GEOGRAPHICALGRIDSYSTEMS.PLANIGNV2&style=normal&tilematrixset=PM&Service=WMTS&Request=GetTile&Version=1.0.0&Format=image%2Fpng&TileMatrix={z}&TileCol={x}&TileRow={y}",
    .ign25: "https://wxs.ign.fr/an7nvfzojv5wa96dsga5nk8w/geoportail/wmts?layer=GEOGRAPHICALGRIDSYSTEMS.MAPS&style=normal&tilematrixset=PM&Service=WMTS&Request=GetTile&Version=1.0.0&Format=image%2Fjpeg&TileMatrix={z}&TileCol={x}&TileRow={y}",
    .openStreetMap: "https://a.tile.openstreetmap.org/{z}/{x}/{y}.png",
    .openTopoMap: "https://b.tile.opentopomap.org/{z}/{x}/{y}.png",
    .swissTopo: "https://wmts.geo.admin.ch/1.0.0/ch.swisstopo.pixelkarte-farbe/default/current/3857/{z}/{x}/{y}.jpeg",
    .hasuriski: "http://akusok.asuscomm.com:9000/elevation/predict_terrain/{z}/{x}/{y}.png",
    .gtkEnnako: "http://akusok.asuscomm.com:9000/elevation/hasuriski_ennako/{z}/{x}/{y}.png",
]

let mapTileOverlays: [Layer: MKTileOverlay] = [
    .ign: MKTileOverlay(urlTemplate:"https://wxs.ign.fr/pratique/geoportail/wmts?layer=GEOGRAPHICALGRIDSYSTEMS.PLANIGNV2&style=normal&tilematrixset=PM&Service=WMTS&Request=GetTile&Version=1.0.0&Format=image%2Fpng&TileMatrix={z}&TileCol={x}&TileRow={y}"),
    .ign25: MKTileOverlay(urlTemplate:"https://wxs.ign.fr/an7nvfzojv5wa96dsga5nk8w/geoportail/wmts?layer=GEOGRAPHICALGRIDSYSTEMS.MAPS&style=normal&tilematrixset=PM&Service=WMTS&Request=GetTile&Version=1.0.0&Format=image%2Fjpeg&TileMatrix={z}&TileCol={x}&TileRow={y}"),
    .openStreetMap: MKTileOverlay(urlTemplate:"https://a.tile.openstreetmap.org/{z}/{x}/{y}.png"),
    .openTopoMap: MKTileOverlay(urlTemplate:"https://b.tile.opentopomap.org/{z}/{x}/{y}.png"),
    .swissTopo: MKTileOverlay(urlTemplate:"https://wmts.geo.admin.ch/1.0.0/ch.swisstopo.pixelkarte-farbe/default/current/3857/{z}/{x}/{y}.jpeg"),
    .hasuriski: MKTileOverlay(urlTemplate:"http://akusok.asuscomm.com:9000/elevation/predict_terrain/{z}/{x}/{y}.png"),
    .gtkEnnako: MKTileOverlay(urlTemplate:"http://akusok.asuscomm.com:9000/elevation/hasuriski_ennako/{z}/{x}/{y}.png"),
]


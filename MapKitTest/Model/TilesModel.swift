//
//  TilesModel.swift
//  MapKitTest
//
//  Created by Anton on 3.9.2023.
//

import SwiftUI
import MapKit


// // Does not work well, empty screen
//class CustomTileOverlay: MKTileOverlay, ObservableObject {
//
//    @Published var selectedLayer: Layer = .standard
//    
//    static let shared = CustomTileOverlay()
//
//    override func url(forTilePath path: MKTileOverlayPath) -> URL {
//        let overlay: MKTileOverlay = mapTileOverlays[self.selectedLayer]!
//        let url = overlay.url(forTilePath: path)
//        return url
//    }
//    
//}

class TilesModel: ObservableObject {
    
    @Published var selectedLayer: Layer = .standard
    
    static let shared = TilesModel()
    
    func getOverlay() -> MKTileOverlay {
        let overlay = mapTileOverlays[self.selectedLayer]!
        overlay.minimumZ = 2
        overlay.maximumZ = 16
        return overlay
    }
}

//
//  TilesModel.swift
//  MapKitTest
//
//  Created by Anton on 3.9.2023.
//

import SwiftUI
import MapKit


 // Does not work well, empty screen
class CustomTileOverlay: MKTileOverlay {

    init(selectedLayer: Layer) {
        super.init(urlTemplate: mapPaths[selectedLayer])
    }
    
}

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

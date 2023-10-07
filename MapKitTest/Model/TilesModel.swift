//
//  TilesModel.swift
//  MapKitTest
//
//  Created by Anton on 3.9.2023.
//

import SwiftUI
import MapKit


 // Does not work well, empty screen
//class CustomTileOverlay: MKTileOverlay {
//
//    init(selectedLayer: Layer) {
//        super.init(urlTemplate: mapPaths[selectedLayer])
//    }
//    
//}

class TilesModel: ObservableObject {
    
    @Published var selectedLayer: Layer = .standard
    @Published var isGrayscale: Bool = false
    @Published var elm: ELMModel?
    
    static let shared = TilesModel()
    
    func getOverlay() -> MKTileOverlay {
//        let overlay = mapTileOverlays[self.selectedLayer]!
//        let overlay = MKTileOverlay(urlTemplate: mapPaths[self.selectedLayer])
        let urlTemplate = mapPaths[self.selectedLayer]!
        let overlay = CachedTileOverlay(urlTemplate: urlTemplate)
        overlay.elm = elm
        overlay.isGrayscale = isGrayscale
        overlay.minimumZ = 2
        overlay.maximumZ = 16
        return overlay
    }
}

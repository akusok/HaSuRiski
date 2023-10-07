//
//  TilesModel.swift
//  MapKitTest
//
//  Created by Anton on 3.9.2023.
//

import SwiftUI
import MapKit


class TilesModel: ObservableObject {    
    @Published var selectedLayer: Layer = .standard
    @Published var elm: ELMModel?
    
    static let shared = TilesModel()
    
    func getOverlay() -> MKTileOverlay {
        let urlTemplate = mapPaths[self.selectedLayer]!
        let overlay = CachedTileOverlay(urlTemplate: urlTemplate)
        overlay.selectedLayer = selectedLayer
        overlay.elm = elm
        overlay.minimumZ = 2
        overlay.maximumZ = 15
        return overlay
    }
}

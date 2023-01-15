//
//  TilesOverlay.swift
//  HaSuRiski
//
//  Created by Anton on 15.1.2023.
//

import SwiftUI
import MapKit

class TilesOverlay: MKTileOverlay {
    override func url(forTilePath path: MKTileOverlayPath) -> URL {
        let bucket = "http://akusok.asuscomm.com:9000/elevation/"
        let tilePath = "TILES_hillshade2/\(path.z)/\(path.x)/\(path.y).png"
        if let url = URL(string: bucket + tilePath) {
            return url
        } else {
            return URL(string: "none")!
        }
    }
}

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

func getOverlay() -> MKTileOverlay {
    let bucket = "http://akusok.asuscomm.com:9000/elevation/"
    let tileOverlay = MKTileOverlay(urlTemplate: bucket + "TILES_hillshade2/{z}/{x}/{y}.png")
    tileOverlay.minimumZ = 2
    tileOverlay.maximumZ = 16
    return tileOverlay
}

func getCustomOverlay() -> MKTileOverlay {
    // create tiles with --xyz flag for gdal2tiles.py
    let tileOverlay = TilesOverlay()
    tileOverlay.minimumZ = 2
    tileOverlay.maximumZ = 16
    return tileOverlay
}

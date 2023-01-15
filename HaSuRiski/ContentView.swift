//
//  ContentView.swift
//  HaSuRiski
//
//  Created by Anton on 15.1.2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TilesMapView(overlay: getCustomOverlay())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

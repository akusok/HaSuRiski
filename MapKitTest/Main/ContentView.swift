//
//  ContentView.swift
//  deleteme
//
//  Created by Anton on 3.9.2023.
//

import SwiftUI

struct ContentView: View {

    @State var selectedLayer: Layer = .ign25
    
    var body: some View {
        VStack {
            MapView(selectedLayer: $selectedLayer)
                .edgesIgnoringSafeArea(.all)
            
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

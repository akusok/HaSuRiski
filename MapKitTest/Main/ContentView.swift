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
                        
            Text("Select map layer")
                .padding(.top)
            
            Picker("Select map layer", selection: $selectedLayer) {
                ForEach(Layer.allCases, id: \.id) { value in
                    Text(value.localized)
                        .tag(value)
                }
            }
        }
        .ignoresSafeArea()
        .padding(.bottom)
    }
}

#Preview {
    ContentView()
}

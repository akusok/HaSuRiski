//
//  ContentView.swift
//  deleteme
//
//  Created by Anton on 3.9.2023.
//

import SwiftUI
import MapKit

struct ContentView: View {

    @State var selectedLayer: Layer = .standard
    @StateObject private var viewModel = LocationsViewModel()
    @StateObject private var elm = ELMModel.buildELM()
    
    var body: some View {
        ZStack {
            MapView(selectedLayer: $selectedLayer, region: $viewModel.mapRegion)
                .ignoresSafeArea()
                    
            // at the center
            Circle()
                .fill(.blue)
                .opacity(0.3)
                .frame(width: 32)
                .allowsHitTesting(false)
            
            VStack {
                HStack {
                    SaveButton()
                    LoadButton()
                    Spacer()
                    
                    Picker("Select map layer", selection: $selectedLayer) {
                        ForEach(Layer.allCases, id: \.id) { Text($0.localized) }
                    }
                    .accentColor(.black)
                    .background(.white.opacity(0.7))
                    .cornerRadius(8)
                    .padding(.trailing)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    AddPinButton(isAS: false, bgColor: .green.opacity(0.85))
                    AddPinButton(isAS: true, bgColor: .red.opacity(0.75))
                }
            }
        }
        .environmentObject(viewModel)
        .environmentObject(elm)
    }
}


struct ContentView_Previews: PreviewProvider {
    
    static let loc = LocationsViewModel()
    static let elm = ELMModel.buildELM()
    
    static var previews: some View {
        ContentView()
            .environmentObject(loc)
            .environmentObject(elm)
    }
}

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
    @State var selectedLocation: Location? = nil
    @State var editingLocations = false

    @StateObject private var viewModel: LocationsViewModel = .shared
    @StateObject private var elm = ELMModel.buildELM()
    
    private var isLocationViewDisplayed: Bool { selectedLocation != nil }
    
    var body: some View {
        ZStack {
            MapView(
                selectedLayer: $selectedLayer,
                region: $viewModel.mapRegion,
                locations: $viewModel.locations,
                selectedLocation: $selectedLocation
            )
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
                    
                    Button {
                        editingLocations.toggle()
                    } label: {
                        Image(systemName: "eraser")
                    }
                    .padding()
                    .background(.gray)
                    .foregroundColor(.white)
                    .font(.title)
                    .clipShape(Circle())
                    .padding(.leading)

                    Spacer()
                    AddPinButton(isAS: false, bgColor: .green.opacity(0.85))
                    AddPinButton(isAS: true, bgColor: .red.opacity(0.75))
                }
            }
        }
        .sheet(item: $selectedLocation) { place in
            LocationEditView(location: place) {
                viewModel.updateLocation($0, old: selectedLocation)
            }
        }
        .sheet(isPresented: $editingLocations) {
            NavigationStack {
                LocationsListView(vm: viewModel)
                    .navigationTitle("Remove locations")
//                    .toolbar {
//                        ToolbarItem(placement: .confirmationAction) {
//                            Button("Done") {
//                                editingLocations = false
//                            }
//                        }
//                    }
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

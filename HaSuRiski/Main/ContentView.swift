//
//  ContentView.swift
//  deleteme
//
//  Created by Anton on 3.9.2023.
//

import SwiftUI
import MapKit
//import CoreLocation

struct ContentView: View {

    @State var selectedLayer: Layer = .standard
    @State var selectedLocation: Location? = nil
    @State var editingLocations = false
    @State var locationViewModel = LocationViewModel()

    @StateObject private var viewModel: LocationsViewModel = .shared
    
    private var isLocationViewDisplayed: Bool { selectedLocation != nil }
    
    var body: some View {
        
        // location permissions
        switch locationViewModel.authorizationStatus {
        case .notDetermined:
            AnyView(RequestLocationView())
                .environmentObject(locationViewModel)
        case .restricted:
            ErrorView(errorText: "Location use is restricted.")
        case .denied:
            ErrorView(errorText: "The app does not have location permissions. Please enable them in settings.")
        case .authorizedAlways, .authorizedWhenInUse:
            EmptyView()
                .environmentObject(locationViewModel)
        default:
            Text("Unexpected status")
        }

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
                    RemoveLocationsButton(editingLocations: $editingLocations)
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
            }
        }
        .environmentObject(viewModel)
    }
}


struct ContentView_Previews: PreviewProvider {
    
    static let loc = LocationsViewModel()
    
    static var previews: some View {
        ContentView()
            .environmentObject(loc)
    }
}

//
//  ContentView.swift
//  HaSuRiski
//
//  Created by Anton on 15.1.2023.
//

import SwiftUI
import MapKit


struct ContentView: View {
    
    // cannot move Appearance attributes out of Content View
    private let mapAppearanceInstance = MKMapView.appearance()
    private var mapCustomDelegate: MapCustomDelegate = MapCustomDelegate(MKMapView.appearance())

    @StateObject private var viewModel = ViewModel()
        
    var body: some View {
        if viewModel.isUnlocked {
            ZStack {
                Map(coordinateRegion: $viewModel.mapRegion, annotationItems: viewModel.locations) { location in
                    MapAnnotation(coordinate: location.coordinate) {
                        Image(systemName: "star.circle")
                            .resizable()
                            .foregroundColor(getPinColor(location.acidity))
                            .frame(width: 32, height: 32)
                            .background(.white)
                            .clipShape(Circle())
                            .onTapGesture {
                                viewModel.selectedLocation = location
                            }
                    }
                }
                .onAppear {
                    self.mapAppearanceInstance.delegate = mapCustomDelegate
                    self.mapAppearanceInstance.addOverlay(getCustomOverlay())
                }
                .ignoresSafeArea()
                Circle()
                    .fill(.blue)
                    .opacity(0.3)
                    .frame(width: 32)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            viewModel.addLocation(acidity: SOIL_NORMAL_PH)
                        } label: {
                            Image(systemName: "plus")
                        }
                        .padding()
                        .background(.green.opacity(0.85))
                        .foregroundColor(.white)
                        .font(.title)
                        .clipShape(Circle())
                        .padding(.trailing)
                        
                        Button {
                            viewModel.addLocation(acidity: SOIL_ACID_PH)
                        } label: {
                            Image(systemName: "plus")
                        }
                        .padding()
                        .background(.red.opacity(0.75))
                        .foregroundColor(.white)
                        .font(.title)
                        .clipShape(Circle())
                        .padding(.trailing)
                    }
                }
            }
            .sheet(item: $viewModel.selectedLocation) { place in
                LocationEditView(location: place) { viewModel.updateLocation($0) }
            }
        } else {
            // show button to unlock
            Button("Unlock Annotations") {
                viewModel.authenticate()
            }
            .padding()
            .background(.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

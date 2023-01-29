//
//  ContentView.swift
//  HaSuRiski
//
//  Created by Anton on 15.1.2023.
//

import SwiftUI
import MapKit


struct ContentView: View {
    
    @StateObject private var viewModel = ViewModel()

    // this thing glues overlay to SwiftUI Map, until a proper way is implemented
    private let mapAppearanceInstance = MKMapView.appearance()
    private var mapCustomDelegate: MapCustomDelegate = MapCustomDelegate(MKMapView.appearance())
    
    class MapCustomDelegate: NSObject, MKMapViewDelegate {
        var parent: MKMapView
        
        init(_ parent: MKMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let tileOverlay = overlay as? MKTileOverlay {
                let renderer = MKTileOverlayRenderer(overlay: tileOverlay)
                renderer.alpha = 0.75
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
    
    var body: some View {
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
                    Button {
                        viewModel.showingExporter.toggle()
                    } label: {
                        Image(systemName: "square.and.arrow.up.circle")
                    }
                    .padding(.leading)
                    .foregroundColor(.blue.opacity(0.75))
                    .font(.system(size: 55))
                    .fileExporter(isPresented: $viewModel.showingExporter, document: LocationDoc(content: viewModel.locations), contentType: .text) { result in }
                    
                    Spacer()
                    
                    Button {
                        viewModel.addLocation(acidity: PH.NORMAL)
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
                        viewModel.addLocation(acidity: PH.ACID)
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

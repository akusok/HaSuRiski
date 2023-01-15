//
//  ContentView.swift
//  HaSuRiski
//
//  Created by Anton on 15.1.2023.
//

import SwiftUI
import MapKit

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

struct ContentView: View {
    private let mapAppearanceInstance = MKMapView.appearance()
    private var mapCustomDelegate: MapCustomDelegate = MapCustomDelegate(MKMapView.appearance())

    @State var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 65.49, longitude: 25.50),
        span: MKCoordinateSpan(latitudeDelta: 12.0, longitudeDelta: 9.0))
    
    @State private var annotations = [Location]()
        
    var body: some View {
        ZStack {
            Map(coordinateRegion: $mapRegion, annotationItems: annotations) { location in
                MapMarker(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
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
                        let newLocation = Location(id: UUID(), name: "New", acidity: 7.0, latitude: mapRegion.center.latitude, longitude: mapRegion.center.longitude)
                        annotations.append(newLocation)
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

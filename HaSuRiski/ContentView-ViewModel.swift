//
//  ContentView-ViewModel.swift
//  HaSuRiski
//
//  Created by Anton Akusok on 22.01.23.
//

import Foundation
import MapKit

extension ContentView {
    
    // tab this class inside our ContentView
    // UI updates must happen on the @MainActor
    // every time I make a class conforming to
    // the ObservableObject, add a @MainActor
    @MainActor class ViewModel: ObservableObject {
        
        @Published private(set) var locations = [Location]()
        @Published var selectedLocation: Location?

        @Published var mapRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 65.49, longitude: 25.50),
            span: MKCoordinateSpan(latitudeDelta: 12.0, longitudeDelta: 9.0))

        func addLocation(acidity: Double) {
            let newLocation = Location(
                id: UUID(),
                name: "New",
                acidity: acidity,
                latitude: mapRegion.center.latitude,
                longitude: mapRegion.center.longitude
            )
            locations.append(newLocation)
        }
        
        func updateLocation(_ newLocation: Location) {
            guard let selectedPlace = selectedLocation else { return }
            
            if let index = locations.firstIndex(of: selectedPlace) {
                locations[index] = newLocation
            }
        }
    }
    
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
}

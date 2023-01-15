//
//  TilesMapView.swift
//  HaSuRiski
//
//  Created by Anton on 15.1.2023.
//

import SwiftUI
import MapKit

struct TilesMapView: UIViewRepresentable {
    var overlay: MKTileOverlay
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: TilesMapView
        
        init(_ parent: TilesMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKTileOverlayRenderer(overlay: overlay)
            renderer.alpha = 0.8
            return renderer
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 65.49, longitude: 25.50),
            span: MKCoordinateSpan(latitudeDelta: 12.0, longitudeDelta: 9.0)
        )
        mapView.addOverlay(overlay)
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.delegate = context.coordinator
    }
}

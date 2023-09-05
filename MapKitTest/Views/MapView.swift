//
//  MapView.swift
//  MapKitTest
//
//  Created by Anton on 3.9.2023.
//

import SwiftUI
import UIKit
import MapKit

struct MapView: UIViewRepresentable {
    
    @Binding var selectedLayer: Layer
    private let tilesModel = TilesModel.shared
        
    init(selectedLayer: Binding<Layer>) {
        self._selectedLayer = selectedLayer
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            switch overlay {
            case let overlay as MKTileOverlay:
                return MKTileOverlayRenderer(tileOverlay: overlay)
            default:
                return MKOverlayRenderer()
            }
        }
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        self.configureMap(mapView: mapView)
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        setOverlays(mapView: uiView)
    }
    
    private func configureMap(mapView: MKMapView) {
        mapView.showsTraffic = false
        mapView.showsBuildings = false
        mapView.showsUserLocation = true
        mapView.showsScale = true
        mapView.tintColor = .blue
        mapView.isPitchEnabled = true
        mapView.showsCompass = true // Remove default
    }
    
    private func setOverlays(mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        switch selectedLayer {
        case .satellite:
            mapView.mapType = .hybrid
        case .flyover:
            mapView.mapType = .hybridFlyover
        case .standard:
            mapView.mapType = .standard
        default:
            tilesModel.selectedLayer = selectedLayer
            let overlay = tilesModel.getOverlay()
            overlay.canReplaceMapContent = false
            mapView.mapType = .mutedStandard
            mapView.addOverlay(overlay, level: .aboveLabels)
        }
    }
}

// MARK: Previews
struct MapView_Previews: PreviewProvider {
    @State static var selectedLayer: Layer = .ign25
    
    static var previews: some View {
        MapView(selectedLayer: $selectedLayer)
            .previewDevice(PreviewDevice(rawValue: "iPhone X"))
            .previewDisplayName("iPhone X")
            .environment(\.colorScheme, .dark)
    }
}

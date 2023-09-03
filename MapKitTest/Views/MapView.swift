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
            let overlay: MKTileOverlay
            switch selectedLayer {
            case .openStreetMap:
                overlay = OpenStreetMapOverlay
            case .openTopoMap:
                overlay = OpenTopoMapOverlay
            case .swissTopo:
                overlay = SwissTopoMapOverlay
            case .ign25:
                overlay = IGN25Overlay
            case .hasuriski:
                overlay = PredictTerrain
            case .gtkEnnako:
                overlay = GTKEnnako
            default: //ign
                overlay = IGNV2Overlay
            }
            overlay.canReplaceMapContent = false
            // Other type underneath the overlay not used in standard/hybrid/hybridFlyover cases to track changes
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

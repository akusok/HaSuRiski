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
    
    @EnvironmentObject var locationsModel: LocationsViewModel
    @EnvironmentObject var elm: ELMModel
    @Binding var selectedLayer: Layer
    @Binding var isGrayscale: Bool
    @Binding var region: MKCoordinateRegion
    private let tilesModel = TilesModel.shared
    private var locationsCount: Int = 0

    init(selectedLayer: Binding<Layer>, region: Binding<MKCoordinateRegion>, isGrayscale: Binding<Bool>) {
        self._selectedLayer = selectedLayer
        self._region = region
        self._isGrayscale = isGrayscale
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
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            parent.region = mapView.region
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let annotation = annotation as? LocAnnotation {
                let identifier = "Annotation"
                var view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                if let view = view {
                    view.annotation = annotation
                } else {
                    view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    view?.canShowCallout = true
                }
                if let view = view as? MKMarkerAnnotationView {
                    view.glyphImage = annotation.markerGlyph
                    view.markerTintColor = annotation.markerColor
                }
                return view
            } else {
                return nil
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
        setAnnotations(mapView: uiView)
    }
    
    private func configureMap(mapView: MKMapView) {
        mapView.showsTraffic = false
        mapView.showsBuildings = false
        mapView.showsUserLocation = true
        mapView.showsScale = true
        mapView.tintColor = .blue
        mapView.isPitchEnabled = true
        mapView.showsCompass = true // Remove default
        mapView.setRegion(region, animated: true)
    }
    
    private func setOverlays(mapView: MKMapView) {
        
        let currentTileOverlay = mapView.overlays.first { $0 is MKTileOverlay}
        var layerHasChanged: Bool
        switch selectedLayer {
        case .satellite:
            layerHasChanged = mapView.mapType != .hybrid
        case .flyover:
            layerHasChanged = mapView.mapType != .hybridFlyover
        case .standard:
            layerHasChanged = mapView.mapType != .standard
        default:
            if let overlay = currentTileOverlay as? CachedTileOverlay {
                layerHasChanged = overlay.selectedLayer != selectedLayer
            } else {
                layerHasChanged = true
            }
        }

        // still on the same layer, nothing to do
        guard layerHasChanged else { return }
        
        mapView.removeOverlays(mapView.overlays)
        switch selectedLayer {
        case .satellite:
            mapView.mapType = .hybrid
        case .flyover:
            mapView.mapType = .hybridFlyover
        case .standard:
            mapView.mapType = .standard
        default:
            tilesModel.elm = elm
            tilesModel.selectedLayer = selectedLayer
            tilesModel.isGrayscale = isGrayscale
            let overlay = tilesModel.getOverlay()
            overlay.canReplaceMapContent = false
            mapView.mapType = .mutedStandard
            mapView.addOverlay(overlay, level: .aboveLabels)
        }
    }
    
    private func setAnnotations(mapView: MKMapView) {
        let previousAnnotations = mapView.annotations
        let annotations = self.locationsModel.locations.map { LocAnnotation(poi: $0) }
        if previousAnnotations.count != annotations.count {
            mapView.removeAnnotations(previousAnnotations)
            mapView.addAnnotations(annotations)
        }
    }

}

// MARK: Previews
struct MapView_Previews: PreviewProvider {
    @State static var selectedLayer: Layer = .ign25
    @State static var loc = LocationsViewModel()
    @State static var elm = ELMModel.buildELM()
    @State static var isGrayscale = false
    @State static var myMap = MapView(selectedLayer: $selectedLayer, region: $loc.mapRegion, isGrayscale: $isGrayscale)
    
    static var previews: some View {
        myMap
            .previewDevice(PreviewDevice(rawValue: "iPhone X"))
            .previewDisplayName("iPhone X")
            .environment(\.colorScheme, .dark)
            .environmentObject(loc)
            .environmentObject(elm)
    }
}

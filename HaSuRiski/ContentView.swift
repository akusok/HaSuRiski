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

func getPinColor(_ acidity: Double) -> Color {
    // acidity is interpolated at 5.6==red, 7.0==green
    // setup by global constants in HaSuRiskiApp.swift
    let acidityFraction: Double
    
    switch acidity {
        case SOIL_NORMAL_PH...:
            acidityFraction = 0.0
        case ...SOIL_ACID_PH:
            acidityFraction = 1.0
        default:
            acidityFraction = (SOIL_NORMAL_PH - acidity) / (SOIL_NORMAL_PH - SOIL_ACID_PH)
    }
    
    let pinColor = UIColor(Color.green).mix(end: UIColor(Color.red), fraction: acidityFraction)
    
    return Color(pinColor)
}

struct ContentView: View {
    
    private let mapAppearanceInstance = MKMapView.appearance()
    private var mapCustomDelegate: MapCustomDelegate = MapCustomDelegate(MKMapView.appearance())

    @State var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 65.49, longitude: 25.50),
        span: MKCoordinateSpan(latitudeDelta: 12.0, longitudeDelta: 9.0))
    
    @State private var annotations = [Location]()
    @State private var selectedAnnotation: Location?
        
    var body: some View {
        ZStack {
            Map(coordinateRegion: $mapRegion, annotationItems: annotations) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    Image(systemName: "star.circle")
                        .resizable()
                        .foregroundColor(getPinColor(location.acidity))
                        .frame(width: 32, height: 32)
                        .background(.white)
                        .clipShape(Circle())
                        .onTapGesture {
                            selectedAnnotation = location
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
                        let newLocation = Location(id: UUID(), name: "New", acidity: 7.0, latitude: mapRegion.center.latitude, longitude: mapRegion.center.longitude)
                        annotations.append(newLocation)
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
                        let newLocation = Location(id: UUID(), name: "New annotation", acidity: 5.7, latitude: mapRegion.center.latitude, longitude: mapRegion.center.longitude)
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
        .sheet(item: $selectedAnnotation) { place in
            AnnotationEditView(location: place) { newAnnotation in
                if let index = annotations.firstIndex(of: place) {
                    annotations[index] = newAnnotation
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

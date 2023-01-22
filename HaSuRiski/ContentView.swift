//
//  ContentView.swift
//  HaSuRiski
//
//  Created by Anton on 15.1.2023.
//

import SwiftUI
import MapKit


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
    
    // cannot move Appearance attributes out of Content View
    private let mapAppearanceInstance = MKMapView.appearance()
    private var mapCustomDelegate: MapCustomDelegate = MapCustomDelegate(MKMapView.appearance())

    @StateObject private var viewModel = ViewModel()
        
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  ContentView-ViewModel.swift
//  HaSuRiski
//
//  Created by Anton Akusok on 22.01.23.
//

import Foundation
import MapKit

struct PH {
    static let NORMAL = 7.0  // normal PH soil
    static let ACID = 5.6    // 100% acid sulfate soil
}

extension ContentView {
    
    // tab this class inside our ContentView
    // UI updates must happen on the @MainActor
    // every time I make a class conforming to
    // the ObservableObject, add a @MainActor
    @MainActor class ViewModel: ObservableObject {
        
        // can init with ` = [Location]()`
        // or set type `: [Location]` and initialize at init()
        // or set `: [Location]!` and initialize at a function called by init()
        @Published private(set) var locations: [Location]
        @Published var selectedLocation: Location?
        @Published var showingExporter = false
        @Published var showingImporter = false

        @Published var mapRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 65.49, longitude: 25.50),
            span: MKCoordinateSpan(latitudeDelta: 12.0, longitudeDelta: 9.0))

        let savePath = FileManager.documentDirectory.appendingPathComponent("SavedPlaces")
        
        init() {
            // avoid calling sub-function because init works with half-initialized
            // instance of a class, and needs workarounds calling sub-functions
            do {
                let data = try Data(contentsOf: savePath)
                locations = try JSONDecoder().decode([Location].self, from: data)
            } catch {
                locations = []
            }
        }
        
        func saveLocations() {
            do {
                let data = try JSONEncoder().encode(locations)
                try data.write(to: savePath, options: [.atomicWrite, .completeFileProtection])
            } catch {
                print("Unable to save data.")
            }
        }
        
        func setLocations(_ newLocations: [Location]) {
            locations = newLocations
        }
        
        func addLocation(acidity: Double) {
            let newLocation = Location(
                id: UUID(),
                name: "New",
                acidity: acidity,
                latitude: mapRegion.center.latitude,
                longitude: mapRegion.center.longitude
            )
            locations.append(newLocation)
            saveLocations()
        }
        
        func updateLocation(_ newLocation: Location) {
            guard let selectedPlace = selectedLocation else { return }
            
            if let index = locations.firstIndex(of: selectedPlace) {
                locations[index] = newLocation
                saveLocations()
            }
        }
    }
    
}


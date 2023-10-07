//
//  ContentView-ViewModel.swift
//  HaSuRiski
//
//  Created by Anton Akusok on 22.01.23.
//

import Foundation
import MapKit

final class LocationsViewModel: ObservableObject {
    
    static let shared: LocationsViewModel = .init()

    @Published var locations: [Location]
    @Published var showingExporter = false
    @Published var showingImporter = false
    private let savePath: URL

    @Published var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 65.49, longitude: 25.50),
        span: MKCoordinateSpan(latitudeDelta: 12.0, longitudeDelta: 9.0))

    
    init() {
        // let savePath = FileManager.documentDirectory.appendingPathComponent("SavedPlaces")
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        self.savePath = documentsDirectory.appendingPathComponent("SavedPlaces")

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
    
    func addLocation(isAcidSulfate: Bool) {
        let newLocation = Location(
            id: UUID(),
            name: "New",
            acidSulfate: isAcidSulfate,
            latitude: mapRegion.center.latitude,
            longitude: mapRegion.center.longitude
        )
        locations.append(newLocation)
        saveLocations()
    }
    
    func updateLocation(_ newLocation: Location, old oldLocation: Location?) {
        guard let oldLocation = oldLocation else {
            print("No location selected")
            return
        }
        
        if let index = locations.firstIndex(of: oldLocation) {
            locations[index] = newLocation
            saveLocations()
        }
    }
}


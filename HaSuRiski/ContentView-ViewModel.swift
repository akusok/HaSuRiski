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
    // every time I make a class conforming to the ObservableObject, add a @MainActor
    @MainActor class ViewModel: ObservableObject {
        @Published var annotations = [Location]()
        @Published var selectedAnnotation: Location?

    }
}

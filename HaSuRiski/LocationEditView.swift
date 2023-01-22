//
//  AnnotationEditView.swift
//  HaSuRiski
//
//  Created by Anton on 15.1.2023.
//

import SwiftUI

struct LocationEditView: View {
    enum LoadingState {
        case loading, loaded, failed
    }
    
    @Environment(\.dismiss) var dismiss
    var location: Location
    var onSave: (Location) -> Void

    @State private var name: String
    @State private var acidity: Double
    
    // default state is "currently loading data"
    @State private var loadingState = LoadingState.loading
    
    // we don't care about query or result in the SwiftUI layout
    // only storing the array of actual pages coming back
    @State private var pages = [Page]()
        
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name", text: $name)
                    
                    VStack {
                        Slider(value: $acidity, in: SOIL_ACID_PH...SOIL_NORMAL_PH, step: 0.1) {
                            Text("Acidity")
                        } minimumValueLabel: {
                            Text(String(format: "≤ %.1f", SOIL_ACID_PH))
                                .foregroundColor(.red)
                        } maximumValueLabel: {
                            Text(String(format: "≥ %.1f", SOIL_NORMAL_PH))
                                .foregroundColor(.green)
                        }
                        Text(String(format: "Soil acidity PH: %.1f", acidity))
                            .foregroundColor(getPinColor(acidity))
                    }
                }
                Section("Nearby...") {
                    switch loadingState {
                    case .loading:
                        Text("Loading...")
                    case .loaded:
                        // have Wikipedia data back, time to show it on the screen
                        ForEach(pages, id: \.pageid) { page in
                            Text(page.title)
                                .font(.headline)
                            + Text(": ")
                            + Text(page.description)
                                .italic()
                        }
                    case .failed:
                        Text("Please try again later.")
                    }
                }
            }
            .navigationTitle("Annotation details")
            .toolbar {
                Button("Save") {
                    var newLocation = location
                    newLocation.id = UUID()
                    newLocation.name = name
                    newLocation.acidity = acidity
                    
                    onSave(newLocation)
                    dismiss()
                }
            }
            .task {
                await fetchNearbyPlaces()
            }
        }
    }
    
    
    init(location: Location, onSave: @escaping (Location) -> Void) {
        self.location = location
        self.onSave = onSave
        
        _name = State(initialValue: location.name)
        _acidity = State(initialValue: location.acidity)
    }
    
    func fetchNearbyPlaces() async {
        let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(location.coordinate.latitude)%7C\(location.coordinate.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"
        
        guard let url = URL(string: urlString) else {
            print("Bad URL: \(urlString)")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let returnedItems = try JSONDecoder().decode(Result.self, from: data)
            pages = returnedItems.query.pages.values.sorted()
            loadingState = .loaded
        } catch {
            loadingState = .failed
        }
    }
    
}

struct AnnotationEditView_Previews: PreviewProvider {
    static var previews: some View {
        LocationEditView(location: Location.example) { newLocation in }
    }
}

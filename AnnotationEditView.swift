//
//  AnnotationEditView.swift
//  HaSuRiski
//
//  Created by Anton on 15.1.2023.
//

import SwiftUI

struct AnnotationEditView: View {
    @Environment(\.dismiss) var dismiss
    var location: Location
    var onSave: (Location) -> Void

    @State private var name: String
    @State private var acidity: Double
    
    init(location: Location, onSave: @escaping (Location) -> Void) {
        self.location = location
        self.onSave = onSave
        
        _name = State(initialValue: location.name)
        _acidity = State(initialValue: location.acidity)
    }
        
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
        }
    }
}

struct AnnotationEditView_Previews: PreviewProvider {
    static var previews: some View {
        AnnotationEditView(location: Location.example) { newLocation in }
    }
}

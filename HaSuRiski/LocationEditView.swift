//
//  AnnotationEditView.swift
//  HaSuRiski
//
//  Created by Anton on 15.1.2023.
//

import SwiftUI

struct LocationEditView: View {
    
    @Environment(\.dismiss) var dismiss
    var location: Location
    var onSave: (Location) -> Void

    @State private var name: String
    @State private var acidSulfate: Bool
            
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name", text: $name)
                    VStack {
                        Toggle(acidSulfate ? "Acid Sulfate soil" : "Normal Soil", isOn: $acidSulfate)
                            .foregroundColor(acidSulfate ? .red : .green)
                    }
                }
            }
            .navigationTitle("Annotation details")
            .toolbar {
                Button("Save") {
                    var newLocation = location
                    newLocation.id = UUID()
                    newLocation.name = name
                    newLocation.acidSulfate = acidSulfate
                    
                    onSave(newLocation)
                    dismiss()
                }
            }
        }
    }
    
    
    init(location: Location, onSave: @escaping (Location) -> Void) {
        self.location = location
        self.onSave = onSave
        
        _name = State(initialValue: location.name)
        _acidSulfate = State(initialValue: location.acidSulfate)
    }
}

struct AnnotationEditView_Previews: PreviewProvider {
    static var previews: some View {
        LocationEditView(location: Location.example) { newLocation in }
    }
}

//
//  AnnotationEditView.swift
//  HaSuRiski
//
//  Created by Anton on 15.1.2023.
//

import SwiftUI
import MapKit

struct LocationEditView: View {
    
    @Environment(\.dismiss) var dismiss
    var location: Location
    var onSave: (Location) -> Void
    
    @State private var name: String
    @State private var acidSulfate: Bool
    private let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    
    var body: some View {
        NavigationView {
            VStack{
                infoForm.frame(maxHeight: 160)
                mapSection
                    .ignoresSafeArea()
            }
            .navigationTitle("Annotation details")
            .toolbar { saveButton }
        }
    }
    
    
    init(location: Location, onSave: @escaping (Location) -> Void) {
        self.location = location
        self.onSave = onSave
        
        _name = State(initialValue: location.name)
        _acidSulfate = State(initialValue: location.acidSulfate)
    }
}

extension LocationEditView {
    
    private var infoForm: some View {
        Form {
            TextField("Name", text: $name)
            VStack {
                Toggle(acidSulfate ? "Acid Sulfate soil" : "Normal Soil", isOn: $acidSulfate)
                    .foregroundColor(acidSulfate ? .red : .green)
            }
            Text("Data: \(location.x.description)")
                .font(.footnote)
        }
    }
    
    private var saveButton: some View {
        Button("Save") {
            var newLocation = location
            newLocation.id = UUID()
            newLocation.name = name
            newLocation.acidSulfate = acidSulfate
            
            onSave(newLocation)
            dismiss()
        }
    }
    
    private var mapSection: some View {
        Map {
            Annotation(coordinate: location.coordinate, anchor: .bottom) {
                Image(systemName: "star.circle")
                    .resizable()
                    .foregroundColor(acidSulfate ? .red : .green)
                    .frame(width: 32, height: 32)
                    .background(.white)
                    .clipShape(Circle())
            } label: {
                Text(location.name)
            }
        }
    }
}

struct AnnotationEditView_Previews: PreviewProvider {
    static var previews: some View {
        LocationEditView(location: Location.example) { newLocation in }
    }
}

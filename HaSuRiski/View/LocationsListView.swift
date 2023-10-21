//
//  LocationsListView.swift
//  HaSuRiski
//
//  Created by Anton on 7.10.2023.
//

import SwiftUI


struct LocationsListView: View {
    
    @ObservedObject var vm: LocationsViewModel
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.locations, id: \.self) { loc in
                    Text("\(loc.name) (\(loc.acidSulfate ? "as" : "non-as")) at \(loc.latitude), \(loc.longitude)")
                }
                .onDelete(perform: delete)
            }
            .toolbar { 
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        vm.saveLocations()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        vm.loadLocations()
                        dismiss()
                    }
                }
            }
        }
    }

    func delete(at offsets: IndexSet) {
        vm.locations.remove(atOffsets: offsets)
    }
}

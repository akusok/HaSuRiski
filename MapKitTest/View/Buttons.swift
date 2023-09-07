//
//  Buttons.swift
//  HaSuRiski
//
//  Created by Anton Akusok on 2.9.2023.
//

import SwiftUI


struct AddPinButton: View {

    @EnvironmentObject var model: LocationsViewModel
    var isAS: Bool
    var bgColor: Color
    
    var body: some View {
        Button {
            model.addLocation(isAcidSulfate: isAS)
        } label: {
            Image(systemName: "plus")
        }
        .padding()
        .background(bgColor)
        .foregroundColor(.white)
        .font(.title)
        .clipShape(Circle())
        .padding(.trailing)
    }
}

struct SaveButton: View {
    
    @EnvironmentObject var model: LocationsViewModel

    var body: some View {
        Button {
            model.showingExporter.toggle()
        } label: {
            Image(systemName: "square.and.arrow.up.circle")
        }
        .font(.system(size: 50))
        .foregroundColor(.blue.opacity(0.85))
        .background(.white.opacity(0.7))
        .cornerRadius(8)
        .padding(.leading)
        .fileExporter(isPresented: $model.showingExporter, document: LocationDoc(content: model.locations), contentType: .text) { result in }
    }
}

struct LoadButton: View {
    
    @EnvironmentObject var model: LocationsViewModel
    
    var body: some View {
        Button {
            model.showingImporter.toggle()
        } label: {
            Image(systemName: "arrow.down.circle")
        }
        .font(.system(size: 50))
        .foregroundColor(.blue.opacity(0.85))
        .background(.white.opacity(0.7))
        .cornerRadius(8)
//        .fileImporter(isPresented: $model.showingImporter, allowedContentTypes: [.text]) { result in
//            do {
//                let fileUrl = try result.get()
//                
//                if fileUrl.startAccessingSecurityScopedResource() {
//                    let data = try Data(contentsOf: result.get())
//                    let fileLocations = try JSONDecoder().decode([Location].self, from: data)
//                    model.setLocations(fileLocations)
//                }
//                fileUrl.stopAccessingSecurityScopedResource()
//                
//            } catch let error as NSError {
//                fatalError("Error: \(error.localizedDescription)")
//            }
//        }
    }
}

//struct LayersButton: View {
//    var body: some View {
//        Button {
//            // pass
//        } label: {
//            Image(systemName: "map")
//        }
//        .font(.system(size: 40))
//        .foregroundColor(.blue.opacity(0.85))
//        .background(.white.opacity(0.7))
//        .cornerRadius(8)
//        .padding(.trailing)
//    }
//}

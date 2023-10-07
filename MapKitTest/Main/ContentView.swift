//
//  ContentView.swift
//  deleteme
//
//  Created by Anton on 3.9.2023.
//

import SwiftUI
import MapKit

struct ContentView: View {

    @State var selectedLayer: Layer = .standard
    @State var isGrayscale: Bool = false
    @StateObject var viewModel = LocationsViewModel()
    var elm = ELMModel.buildELM()
    

    var body: some View {
        ZStack {
            MapView(selectedLayer: $selectedLayer, region: $viewModel.mapRegion, isGrayscale: $isGrayscale)
                .ignoresSafeArea()
                    
            // at the center
            Circle()
                .fill(.blue)
                .opacity(0.3)
                .frame(width: 32)
                .allowsHitTesting(false)
            
            VStack {
                HStack {
                    SaveButton()
                    LoadButton()
                    Spacer()
                    
                    Picker("Select map layer", selection: $selectedLayer) {
                        ForEach(Layer.allCases, id: \.id) { Text($0.localized) }
                    }
                    .accentColor(.black)
                    .background(.white.opacity(0.7))
                    .cornerRadius(8)
                    .padding(.trailing)
                }
                
                Spacer()
                
                HStack {
                    
                    Button {
                        self.isGrayscale.toggle()
                    } label: {
                        Image(systemName: "eye.fill")
                    }
                    .padding()
                    .background(.gray.opacity(0.75))
                    .foregroundColor(.white)
                    .font(.title)
                    .clipShape(Circle())
                    .padding(.leading)
                    
                    Button {
                        let t0 = CFAbsoluteTimeGetCurrent()
                        
                        Task {
                            await self.elm.getRemoteImage(6, 36, 15)
                        }
                        
                        let loadTasks = Array(1000...1020).map { y in
                            Task {
                                await self.elm.getRemoteImage(12, 2337, y)
                            }
                        }
                        
                        let t1 = CFAbsoluteTimeGetCurrent() - t0
                        print(String(format: "Button press took: %.1f seconds", t1))
                    } label: {
                        Image(systemName: "testtube.2")
                    }
                    .padding()
                    .background(.gray.opacity(0.75))
                    .foregroundColor(.white)
                    .font(.title)
                    .clipShape(Circle())
                    .padding(.leading)
                    
                    Spacer()
                    AddPinButton(isAS: false, bgColor: .green.opacity(0.85))
                    AddPinButton(isAS: true, bgColor: .red.opacity(0.75))
                }
            }
        }
        .environmentObject(viewModel)
    }
}


struct ContentView_Previews: PreviewProvider {
    
    static let loc = LocationsViewModel()
    
    static var previews: some View {
        ContentView()
            .environmentObject(loc)
    }
}

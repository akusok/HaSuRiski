//
//  PHtoPinColor.swift
//  HaSuRiski
//
//  Created by Anton Akusok on 22.1.2023.
//

import Foundation
import SwiftUI


func getPinColor(_ acidity: Double) -> Color {
    // acidity is interpolated at 5.6==red, 7.0==green
    // setup by global constants in HaSuRiskiApp.swift
    let acidityFraction: Double
    
    switch acidity {
        case SOIL_NORMAL_PH...:
            acidityFraction = 0.0
        case ...SOIL_ACID_PH:
            acidityFraction = 1.0
        default:
            acidityFraction = (SOIL_NORMAL_PH - acidity) / (SOIL_NORMAL_PH - SOIL_ACID_PH)
    }
    
    let pinColor = UIColor(Color.green).mix(end: UIColor(Color.red), fraction: acidityFraction)
    
    return Color(pinColor)
}

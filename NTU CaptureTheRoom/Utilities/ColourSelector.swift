//
//  ColourSelector.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 08/03/2025.
//

import SwiftUI

class ColourSelector: ObservableObject {
    
    func getTeamColour(team: String) -> Color{
        switch team {
        case "Grey":
            return .background
        case "Blue":
            return .sstColour
        case "Pink":
            return .actionColour
        default:
            return .white
        }
    }
    
    func getShadowColour(team: String) -> Color{
        switch team {
        case "Grey":
            return .black
        case "Blue":
            return .sstColour
        case "Pink":
            return .actionColour
        default:
            return .white
        }
    }
}

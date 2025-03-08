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
    
    func getShadowColourLeaderboard(team: String) -> Color{
        switch team {
        case "Team Grey":
            return .black
        case "Team Blue":
            return .sstColour
        case "Team Pink":
            return .actionColour
        default:
            return .white
        }
    }
    
    func getLeaderboardOutline(team: String) -> Color{
        switch team{
        case "Team Grey": return .gray
        case "Team Blue": return .sstColour
        case "Team Pink": return .actionColour
            default : return .white
        }
    }
    
    func getTrophyColourAchievements(currentTier: Int) -> Color{
        switch currentTier{
        case 1: return .brown // bronze
        case 2: return .gray // silver
        case 3: return .yellow // gold
        default: return .black // locked trophy
        }
    }
    
    
    
    func getTrophyColourLeaderboard(for index: Int) -> Color{
        switch index {
        case 0:
            return .yellow
        case 1:
            return .gray
        case 2:
            return .brown
        default:
            return .white
        }
    }
}

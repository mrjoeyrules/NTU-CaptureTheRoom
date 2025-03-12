//
//  Achievments.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 08/03/2025.
//
// Similar to user stats with extra steps
import SwiftUI

struct Achievements: View {
    @State private var stepsTaken: Int = 0
    @State private var userLevel: Int = 0
    @State private var roomsCaptured: Int = 0
    @ObservedObject private var colourSelector = ColourSelector()
    
    func getDataFromUserLocal(){
        roomsCaptured = UserLocal.currentUser?.roomsCapped ?? 0
        stepsTaken = UserLocal.currentUser?.totalSteps ?? 0
        userLevel = UserLocal.currentUser?.level ?? 0 // get the user info
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15){
            Text("Achievements") // page title
                .font(.headline)
                .bold()
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center) // centers text
            
            AchievementsRow(title: "Rooms Captured", count: roomsCaptured, thresholds: [5,15,30])
            AchievementsRow(title: "Steps Taken", count: stepsTaken, thresholds: [1000,5000,10000]) // create rows and input the correct info
            AchievementsRow(title: "Player Level", count: userLevel, thresholds: [5,10,20])
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .center)
        .background(Color.background)
        .cornerRadius(15)
        .shadow(color: colourSelector.getShadowColour(team: UserLocal.currentUser?.team ?? "n/a"), radius: 5) // sets shadow to users team colour
        .padding(.horizontal, 20)
        .onAppear{
            getDataFromUserLocal() // on page appear runs this func
        }
    }
}

struct AchievementsRow: View{
    @ObservedObject private var colourSelector = ColourSelector()
    let title: String
    let count: Int
    let thresholds: [Int]
    
    var currentTier: Int{
        if count >= thresholds[2] {return 3} // gold
        if count >= thresholds[1] {return 2} // silver
        if count >= thresholds[0] {return 1} // bronze | what tier the user is on
        return 0 // locked
    }
    
    var progress: CGFloat{
        let minThreshold = currentTier == 0 ? 0 : thresholds[currentTier - 1] // if current tier = 0 then they start from 0 so black trophy.
        // if false take previous tiers threshold
        let maxThreshold = currentTier < thresholds.count ? thresholds[currentTier] : thresholds.last ?? 0 // ensure calcs dont go out of bounds if currentTier < thresholds. if true next milestone from thresholds current tier. thresholds.last ??0 failsafe for final tier so user doesnt go over
        return CGFloat(count - minThreshold) / CGFloat(maxThreshold - minThreshold) // the current progress
        // count - minThreshold. divided by max - min.
    }
    
    var trophyImage: String{
        switch currentTier{
        case 1: return "trophy.fill"
        case 2: return "trophy.fill"
        case 3: return "trophy.fill" // different sfsymbols
        default: return "trophy"
        }
    }
    
    var body: some View{
        VStack(alignment: .leading){
            HStack{
                Image(systemName: trophyImage)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(colourSelector.getTrophyColourAchievements(currentTier: currentTier)) // set colour of image to the current tiers colour
                VStack(alignment: .leading){
                    Text(title)
                        .font(.headline)
                    Text("\(count) / \(thresholds[min(currentTier, thresholds.count - 1)])") // display the progress
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }
                Spacer()
                
            }
            ProgressBarView(progress: progress) // shows the progress bar, passes progress value
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.background.opacity(0.3))) // draws a rectangle around the row
    }
}

struct ProgressBarView : View{
    var progress: CGFloat // progress value from 0.0 - 1.0
    
    var body: some View {
        GeometryReader { geo in // reads the available width from the parent view
            ZStack(alignment: .leading){ // aligns content to the left
                
                RoundedRectangle(cornerRadius: 5) // this is the background bar behind the green progress bar
                    .frame(width: geo.size.width, height: 8) // use full width of parent
                    .foregroundStyle(Color.gray.opacity(0.3)) // lighter grey than standard background
                
                // this is the green progress bar
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: max(progress * geo.size.width, 10), height: 8) // fills depending on the progress passed into it
                    .foregroundStyle(.green) // set colour to green
                    .animation(.easeInOut, value: progress) // little animation when loading in
            }
        }
        .frame(height: 8) // ensures consistant height for the progress bar 
    }
}


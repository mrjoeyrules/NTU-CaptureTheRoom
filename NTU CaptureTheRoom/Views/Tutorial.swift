//
//  Tutorial.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 17/03/2025.
//

import SwiftUI

struct Tutorial: Identifiable{
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
}

struct TutorialPopup: View {
    var step: Tutorial
    var onNext: () -> Void
    
    var body: some View{
        ZStack{
            Color.black.opacity(0.4) // outer dim background
                .ignoresSafeArea()
            VStack(spacing: 20){
                Text(step.title) // step of tutorial title
                    .font(.title)
                    .bold()
                    .foregroundStyle(.white)
                
                
                Image(step.imageName) // step image
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .padding(.horizontal, 30)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(radius: 6)
                
                Text(step.description) // step description
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: onNext){ // button to go next
                    Text("Next")
                        .font(.headline)
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.actionColour)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
            .background(Color.background)
            .cornerRadius(20)
            .shadow(radius: 15)
        }
    }
}

class TutorialManager: ObservableObject {
    @Published var currentStep: Int = 0
    @Published var isTutorialActive: Bool = false
    
    let steps: [Tutorial] = [ // all the different tutorials
        Tutorial(title: "Scan Rooms", description: "Tap the scan button on the map to capture rooms using NFC.", imageName: "pointtonfc"),
        Tutorial(title: "Leaderboard", description: "Tap the graph icon to view which team is leading.", imageName: "pointtoleaderboard"),
        Tutorial(title: "Leaderboard Details", description: "On this screen you can see whos leading. Tap close to close the popup", imageName: "leaderboard"),
        Tutorial(title: "Nearby Rooms", description: "Use the Nearby tab to see rooms close to your location and get directions.", imageName: "pointtonearby"),
        Tutorial(title: "Nearby Rooms Details", description: "Here you can see information about the nearby rooms, press the directions button to get directions to the room.", imageName: "nearby"),
        
        Tutorial(title: "Settings", description: "Access settings by press the Cog button on the profile screen.", imageName: "pointtosettings"),
        Tutorial(title: "Change Map Theme", description: "Go to Settings and choose a map theme that suits your style.", imageName: "pointtotheme"),
        
        Tutorial(title: "Sign Out", description: "In Settings, tap the Sign Out button to log out securely.", imageName: "pointtosignout")
    ]
    
    func nextStep() { // if current step is less than total steps minus 1 then add one
        if currentStep < steps.count - 1 {
            currentStep += 1
        }else{
            isTutorialActive = false // else turn flag off
        }
    }
    
    func restartTutorial(){ // resets current step and flag.
        currentStep = 0
        isTutorialActive = true
    }
}

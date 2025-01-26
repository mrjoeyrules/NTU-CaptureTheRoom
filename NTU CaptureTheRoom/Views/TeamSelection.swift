//
//  TeamSelection.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 29/11/2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI
import SwiftData

struct TeamSelection: View {
    @State private var selectedTeam: String? = nil
    @State private var showAlert: Bool = false
    @State private var navigateToNextPage = false
    func setTeamInFireStore(team: String, completeion: @escaping (Error?) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No authenticated user.")
            completeion(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(uid).updateData([
            "team": team
        ]) { error in
            if let error = error{
                print(error.localizedDescription)
                completeion(error)
            }else{
                UserLocal.currentUser?.team = team
                UserLocal.currentUser?.level = 1
                UserLocal.currentUser?.xp = 0
                completeion(nil)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) { // Vertical stack for the buttons
            Text("Choose Your Team")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
                        Button(action: {
                            selectedTeam = "Grey"
                            showAlert = true
                            print("Selected: \(selectedTeam ?? "")")
                        }) {
                            TeamButtonLabel(teamName: "Team Grey", color: .background)
                        }

                        Button(action: {
                            selectedTeam = "Pink"
                            showAlert = true
                            print("Selected: \(selectedTeam ?? "")")
                        }) {
                            TeamButtonLabel(teamName: "Team Pink", color: .actionColour)
                        }

                        Button(action: {
                            selectedTeam = "Blue"
                            showAlert = true
                            print("Selected: \(selectedTeam ?? "")")
                        }) {
                            TeamButtonLabel(teamName: "Team Blue", color: .sstColour)
                        }
                    }
                    .padding()
                    .background(Color.background.opacity(0.5).ignoresSafeArea())
                    .alert(isPresented: $showAlert){
                        Alert(
                            title: Text("Confirm Team Selection"),
                            message: Text("Are you sure you want to join \(selectedTeam ?? " this team")?"),
                            primaryButton: .default(Text("Confirm")) {
                                if let team = selectedTeam{
                                    setTeamInFireStore(team: team){ error in
                                        if let error = error{
                                            print(error.localizedDescription)
                                        }else{
                                            print("team set properly")
                                            UserLocal.currentUser?.team = team
                                            navigateToNextPage = true
                                        }
                                    }
                                }
                            },
                            secondaryButton: .cancel(Text("Cancel"))
                        )
                    }
                    .navigationDestination(isPresented: $navigateToNextPage){
                        Tabs(selectedTab: .maps)
                    }
        }
        
        
    }
struct TeamButtonLabel: View {
    let teamName: String
    let color: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(color.opacity(0.8))
                .frame(height: 120) // Vertical rectangular shape
                .shadow(color: color.opacity(0.5), radius: 10, x: 0, y: 5)
            
            Text(teamName)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

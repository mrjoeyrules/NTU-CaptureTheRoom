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

// page for selecting what team the user wants to join

struct TeamSelection: View {
    @State private var selectedTeam: String? = nil
    @State private var showAlert: Bool = false
    @State private var navigateToNextPage = false
    
    func setTeamInFireStore(team: String, completeion: @escaping (Error?) -> Void){ // sets the users team in FS
        guard let uid = Auth.auth().currentUser?.uid else { // ensure user is authed to FS access
            print("No authenticated user.")
            completeion(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        let db = Firestore.firestore()
        // get doc with name of users uid in users collection
        db.collection("users").document(uid).updateData([
            "setupstatus": "complete", // final part of user setup so set to complete
            "team": team // set team to team
        ]) { error in
            if let error = error{
                print(error.localizedDescription)
                completeion(error)
            }else{
                UserLocal.currentUser?.setUpStatus = "complete" // set all info in userlocal
                UserLocal.currentUser?.team = team
                UserLocal.currentUser?.level = 1
                UserLocal.currentUser?.xp = 0
                completeion(nil)
            }
        }
    }
    
    var body: some View {
        ZStack{
                Color.background
                    .ignoresSafeArea() // background of page to background colour
            
            VStack(spacing: 20) { // Vertical stack for the buttons
                Text("Choose Your Team")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Button(action: { // button for grey team
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
            .alert(isPresented: $showAlert){
                // alert with confirm and cancel options incase user picks wrong team
                Alert(
                    title: Text("Confirm Team Selection"),
                    message: Text("Are you sure you want to join \(selectedTeam ?? " this team")?"),
                    primaryButton: .default(Text("Confirm")) {
                        if let team = selectedTeam{ // if team is selected team then run store in fs func
                            setTeamInFireStore(team: team){ error in
                                if let error = error{
                                    print(error.localizedDescription)
                                }else{
                                    print("team set properly")
                                    UserLocal.currentUser?.team = team // if done without errors store team in userlocal
                                    navigateToNextPage = true // flag to go to maps
                                }
                            }
                        }
                    },
                    secondaryButton: .cancel(Text("Cancel")) // alert so user can cancel if they dont want that team
                )
            }
            .navigationDestination(isPresented: $navigateToNextPage){
                Tabs(selectedTab: .maps) // if navigation to next page is true go to tabs .maps
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
}

struct TeamButtonLabel: View { // each team label
    let teamName: String
    let color: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15) // rounded rectangle around button
                .fill(color.opacity(0.8))
                .frame(height: 120) // Vertical rectangular shape
                .shadow(color: color.opacity(0.5), radius: 10, x: 0, y: 5) // a little bit of shadow
                .overlay(RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.black, lineWidth: 3))
            
            Text(teamName) // team name being shown
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

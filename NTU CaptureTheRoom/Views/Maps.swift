//
//  Maps.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 02/12/2024.
//


import CoreLocation // Location tracking
import FirebaseAuth // firebase authentication
import FirebaseCore // base firebase
import FirebaseFirestore // firestore
import Foundation
import SwiftUI


// MAPS PAGE

struct Maps: View {
    @State private var userLocation: CLLocationCoordinate2D? = nil
    @StateObject var tutorial = TutorialManager()
    @State private var scanner = NFCScanner()
    @StateObject private var stepManager = StepTrackerManager()
    @State private var showAlert = false
    @State private var showCaptureAlert = false
    @State private var alertMessage = ""
    @State private var roomLocations: [RoomLocation] = [] // all flags and info
    @State private var hasSetInitialCamera = false
    @State private var showLeaderboard = false
    var body: some View {
        NavigationStack {
            ZStack {
                // Map Section
                GoogleMapView(userLocation: $userLocation, roomLocations: $roomLocations, hasSetInitialCamera: $hasSetInitialCamera) // shows the map
                    .edgesIgnoringSafeArea([.top, .leading, .trailing])
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.background)
                
                // Buttons in the top corners
                VStack {
                    HStack {
                        // Leaderboard Button (Top Left)
                        Button(action: {
                            showLeaderboard = true
                        }) {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.actionColour)
                                .clipShape(Circle()) // icon format
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                        .padding(.leading, 10)
                        
                        Spacer()
                        
                        // Scan Room Button (Top Right)
                        Button(action: {
                            scanner.beginScanning { message in
                                self.alertMessage = message // passes alert infomation from NFC scanning stuff
                                self.showAlert = true
                            }
                        }) {
                            Image(systemName: "dot.radiowaves.up.forward")
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.actionColour) // icon format
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                        .padding(.trailing, 10)
                    }
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity)
                    
                    Spacer() // Pushes everything else down
                }
                // show tutorial if flag is true
                if tutorial.isTutorialActive {
                    TutorialPopup(step: tutorial.steps[tutorial.currentStep]){
                        tutorial.nextStep()
                    }
                }
                
                
                
                // Leaderboard Overlay
                if showLeaderboard { // if flag is true show the leaderboard
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture { // if tap outside of leadboard popup close it
                            showLeaderboard = false
                        }
                    LeaderBoard(showLeaderboard: $showLeaderboard) // open leaderboard view
                        .transition(.scale)
                        .zIndex(1)
                }
            }
            .background(Color.background.ignoresSafeArea())
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Room Capture"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                startListeningForRoomUpdates() // on appear of maps page run this
                stepManager.requestPermission { granted in // start tracking steps
                    if granted {
                        stepManager.startTrackingSteps()
                    } else {
                        alertMessage = "User Denied Motion tracking, please enable in settings"
                        showAlert = true
                    }
                }
            }
            .onDisappear {
                stepManager.stopTracking() // on leaving page stop tracking steps
            }
            .navigationBarBackButtonHidden(true) // nav bar button off
        }
    }

    func startListeningForRoomUpdates() { // gets all rooms from fs and adds them to a array of locations for use with markers
        let db = Firestore.firestore()

        db.collection("Rooms").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error getting room updates: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else { return }

            var locations: [RoomLocation] = []

            for doc in documents {
                let data = doc.data()

                if let name = data["roomname"] as? String,
                   let latitude = data["roomlat"] as? Double,
                   let longitude = data["roomlon"] as? Double {
                    let teamOwner = data["teamowner"] as? String ?? "unclaimed" // get all info from fs and save as variables

                    let room = RoomLocation(
                        id: doc.documentID,
                        name: name,
                        latitude: latitude,
                        longitude: longitude,
                        teamOwner: teamOwner // creates an object of RoomLocations and fills the variable with info from fs
                    )

                    locations.append(room) // add to the array of RoomLocations
                } else {
                    print("Skipping invalid document: \(doc.documentID)")
                }
            }

            DispatchQueue.main.async {
                self.roomLocations = locations // after all is done set the roomLocations to the array of locations.
            }
        }
    }
    
}

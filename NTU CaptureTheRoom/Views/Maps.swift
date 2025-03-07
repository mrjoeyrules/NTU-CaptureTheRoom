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


// Acutal page below this

struct Maps: View {
    @State private var userLocation: CLLocationCoordinate2D? = nil
    @State private var scanner = NFCScanner()
    @StateObject private var stepManager = StepTrackerManager()
    @State private var showAlert = false
    @State private var showCaptureAlert = false
    @State private var alertMessage = ""
    @State private var roomLocations: [RoomLocation] = []
    @State private var hasSetInitialCamera = false
    @State private var showLeaderboard = false
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                // Map Section
                GoogleMapView(userLocation: $userLocation, roomLocations: $roomLocations, hasSetInitialCamera: $hasSetInitialCamera) // pass all neeeded parameters for maps set up
                    .edgesIgnoringSafeArea([.top, .leading, .trailing])
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.background)
                
                
                
                HStack{
                    // leaderboard button
                    Button(action: {
                        showLeaderboard = true
                    }) {
                        Image(systemName: "chart.bar.fill")
                            .foregroundStyle(.white)
                            .padding(12)
                            .background(Color.actionColour)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            .padding(.top, 10)
                            .padding(.leading, 10)
                    }
                    
                    
                    // Scan Room Button
                    Button(action: {
                        scanner.beginScanning { message in
                            self.alertMessage = message
                            self.showAlert = true
                        }
                    }) {
                        Image(systemName: "dot.radiowaves.up.forward") // what the scan button looks like
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.actionColour)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            .padding(.top, 10)
                            .padding(.trailing, 10)
                    }
                }
                if showLeaderboard{
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture{
                            showLeaderboard = false
                        }
                    LeaderBoard(showLeaderboard: $showLeaderboard)
                }
            }
            .background(Color.background.ignoresSafeArea())
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Room Capture"), message: Text(alertMessage), dismissButton: .default(Text("OK"))) // alert info
            }
            .onAppear {
                startListeningForRoomUpdates()
                stepManager.requestPermission { granted in
                    if granted {
                        stepManager.startTrackingSteps()
                    }else{
                        alertMessage = "User Denied Motion tracking please enable in settings"
                        showAlert = true
                    }
                }
            }
            .onDisappear{
                stepManager.stopTracking()
            }
            .navigationBarBackButtonHidden(true)
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

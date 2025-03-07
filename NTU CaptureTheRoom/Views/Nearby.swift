//
//  Nearby.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 26/01/2025.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import CoreLocation
import FirebaseAuth

struct RoomLocation2: Identifiable {
    var id: String
    var name: String
    var latitude: Double
    var longitude: Double
    var teamOwner: String?
    var distance: Double
    var mazemaplink: String
}



struct Nearby: View {
    @State private var roomLocations: [RoomLocation2] = [] // gets all rooms so I can use the lat and lon
    @State private var locationManager = LocationManager() // gets user location
    private let refreshInterval: TimeInterval = 5
    @Environment(\.openURL) var openLink
    
    
    
    func fetchRooms() {
        
        guard let userLocation = locationManager.userLocation else{
            print("User location unavailable")
            return
        }
        let db = Firestore.firestore()
        
        db.collection("Rooms").addSnapshotListener { snapshot, error in
            if let error = error {
                print("Error getting room updates: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else { return }
            
            var locations: [RoomLocation2] = []
            
            for doc in documents {
                let data = doc.data()
                
                if let name = data["roomname"] as? String,
                   let latitude = data["roomlat"] as? Double,
                   let mazemaplink = data["mazemaplink"] as? String,
                   let longitude = data["roomlon"] as? Double {
                    let teamOwner = data["teamowner"] as? String ?? "unclaimed"
                    let roomLocation = CLLocation(latitude: latitude, longitude: longitude)
                    let distance = userLocation.distance(from: roomLocation) // dividing from 1000 makes it availabe in kilometers but becuase of how close everything is im leaving it in meters.
                    
                    var room = RoomLocation2(
                        id: doc.documentID,
                        name: name,
                        latitude: latitude,
                        longitude: longitude,
                        teamOwner: teamOwner,
                        distance: distance,
                        mazemaplink: mazemaplink
                    )
                    if room.teamOwner == ""{
                        room.teamOwner = "None"
                    }
                    locations.append(room)
                } else {
                    print("Skipping invalid document: \(doc.documentID)")
                }
            }
            
            roomLocations = locations.sorted { $0.distance < $1.distance } // sorts list of rooms based on distnace to user, closets ones first.
        }
    }
    
    var body: some View {
        VStack{
            Text("Nearby Rooms")
                .font(.title)
                .bold()
            ScrollView{
                LazyVStack(spacing: 10){
                    ForEach(roomLocations) { room in
                        HStack{
                            VStack(alignment: .leading){
                                Text(room.name) // presents room info in box
                                    .font(.headline)
                                Text("Owned By Team: \(room.teamOwner ?? "None")")
                                    .font(.subheadline)
                                Text("Distance: \(String(format: "%.2f", room.distance)) m") // two decimal places formatting
                                    .font(.subheadline)
                            }
                            Spacer()
                            
                            Button(action: {
                                openLink(URL(string: room.mazemaplink)!) // opens mazmaplink from fs in default browser
                            }) {
                                Text("Directions")
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .fill(Color.actionColour)
                                    )
                            }
                        }
                        .padding()
                        .background(Color.background)
                        .cornerRadius(10)
                        .overlay( // outline around box
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.black.opacity(0.5), lineWidth: 3)
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear{
            fetchRooms()
        }
        .onReceive(Timer.publish(every: refreshInterval, on: .main, in: .common).autoconnect()) { _ in // re run to refresh list every currently 5 seconds.
            fetchRooms()
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var userLocation: CLLocation?
    
    override init(){
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        if let location = locations.last{
            DispatchQueue.main.async {
                self.userLocation = location
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        print("Failed to find users locations: \(error.localizedDescription)")
    }
}


//
//  Nearby.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 26/01/2025.
//


// page for nearby rooms
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
    
    
    
    func fetchRooms() { // fetch rooms from FS
        
        guard let userLocation = locationManager.userLocation else{ // get userlocation from location manager
            print("User location unavailable")
            return
        }
        let db = Firestore.firestore()
        
        guard Auth.auth().currentUser != nil else { // ensure user is authed
            print("no user authed firestore access blocked")
            return
        }
        
        DispatchQueue.global(qos: .background).async{ // fetch data in background
        
            db.collection("Rooms").getDocuments { snapshot, error in
                if let error = error {
                    print("Error getting room updates: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                var locations: [RoomLocation2] = []
                
                for doc in documents {
                    let data = doc.data()
                    // get all needed room info from FS
                    
                    if let name = data["roomname"] as? String,
                       let latitude = data["roomlat"] as? Double,
                       let mazemaplink = data["mazemaplink"] as? String,
                       let longitude = data["roomlon"] as? Double {
                        let teamOwner = data["teamowner"] as? String ?? "unclaimed"
                        let roomLocation = CLLocation(latitude: latitude, longitude: longitude)
                        let distance = userLocation.distance(from: roomLocation) // dividing from 1000 makes it availabe in kilometers but becuase of how close everything is im leaving it in meters.
                        
                        var room = RoomLocation2( // CREATE Object of roomlocation2 with data vlues below
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
                        locations.append(room) // append location array with this room
                    } else {
                        print("Skipping invalid document: \(doc.documentID)")
                    }
                }
                DispatchQueue.main.async {
                    self.roomLocations = locations.sorted { $0.distance < $1.distance } // sorts list of rooms based on distnace to user, closets ones first.
                }
            }
        }
    }
    
    var body: some View {
        VStack{
            Text("Nearby Rooms") // page title
                .font(.title)
                .bold()
            ScrollView{ // alows page to be scrollable if there a bunch of rooms
                LazyVStack(spacing: 10){
                    ForEach(roomLocations) { room in
                        HStack{
                            VStack(alignment: .leading){
                                Text(room.name) // presents room info in box
                                    .font(.headline)
                                Text("Owned By Team: \(room.teamOwner ?? "None")") // owned by team text
                                    .font(.subheadline)
                                Text("Distance: \(String(format: "%.2f", room.distance)) m") // two decimal places formatting how many meters away is the room
                                    .font(.subheadline)
                            }
                            Spacer()
                            if let url = URL(string: room.mazemaplink){
                                
                                Button(action: {
                                    openLink(url) // opens mazmaplink from fs in default browser
                                }) {
                                    Text("Directions")
                                        .padding() // pink direction button that loads the mazmaplink in browser
                                        .foregroundColor(.white)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                                .fill(Color.actionColour)
                                        )
                                }
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
        .background(Color.background.ignoresSafeArea()) // background colour
        .navigationBarBackButtonHidden(true) // nav back bar hidden
        .onAppear{
            fetchRooms()
        }
        .onReceive(Timer.publish(every: refreshInterval, on: .main, in: .common).autoconnect()) { _ in // re run to refresh list every currently 5 seconds.
            fetchRooms()
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate { // getting user locations
    private var locationManager = CLLocationManager()
    // very similar to google maps page for location
    @Published var userLocation: CLLocation?
    
    override init(){
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // best accuracy mode
        locationManager.requestWhenInUseAuthorization() // ensure perms are set
        locationManager.startUpdatingLocation() // start updating users location
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        if let location = locations.last{ // get users location on location update
            DispatchQueue.main.async {
                self.userLocation = location // set userlocation variable to users locations
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        print("Failed to find users locations: \(error.localizedDescription)") // if errored display error
    }
}


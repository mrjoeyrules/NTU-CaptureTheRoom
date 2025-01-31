//
//  Maps.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 02/12/2024.
//

import CoreLocation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import Foundation
import GoogleMaps
import SwiftUI
import CoreNFC

// room location setup

struct RoomLocation: Identifiable {
    var id: String
    var name: String
    var latitude: Double
    var longitude: Double
    var teamOwner: String?
}




// google maps setup and tracking

struct GoogleMapView: UIViewRepresentable {
    @Binding var userLocation: CLLocationCoordinate2D?
    @Binding var roomLocations: [RoomLocation]
    @Binding var hasSetInitialCamera: Bool
    
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Preserve aspect ratio
        let scaleFactor = min(widthRatio, heightRatio)
        
        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    
    func createMarkerIcon(with systemName: String, color: String, size: CGFloat) -> UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: size, weight: .bold)
        
        // Get SF Symbol as UIImage
        guard let symbolImage = UIImage(systemName: systemName, withConfiguration: config) else {
            return nil
        }
        
        // Apply color from assets
        let colorFromAssets = UIColor(named: color) ?? UIColor.black
        let tintedSymbol = symbolImage.withTintColor(colorFromAssets, renderingMode: .alwaysOriginal)
        
        return tintedSymbol
    }

    class Coordinator: NSObject, CLLocationManagerDelegate {
        var parent: GoogleMapView
        var locationManager: CLLocationManager?
        var mapView: GMSMapView?

        init(parent: GoogleMapView) {
            self.parent = parent
            super.init()
            setupLocationManager()
        }

        private func setupLocationManager() {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.requestWhenInUseAuthorization()
            locationManager?.startUpdatingLocation()
        }

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else { return }
            parent.userLocation = location.coordinate

            if let mapView = mapView, parent.userLocation != nil {
                if !parent.hasSetInitialCamera {
                    let cameraUpdate = GMSCameraUpdate.setTarget(location.coordinate, zoom: 15) // if userlocation is not nil then on display default to user location
                    mapView.moveCamera(cameraUpdate)
                    DispatchQueue.main.async {
                        self.parent.hasSetInitialCamera = true
                    }
                }
                
            }
        }

        func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
            print("Location Manager error \(error.localizedDescription)")
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> GMSMapView {
        let mapView = GMSMapView(frame: .zero)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        context.coordinator.mapView = mapView
        return mapView
    }

    func updateUIView(_ uiView: GMSMapView, context: Context) {
        uiView.clear()
        if let userLocation = userLocation, !hasSetInitialCamera {
            let cameraUpdate = GMSCameraUpdate.setTarget(userLocation, zoom: 15)
            uiView.moveCamera(cameraUpdate)
            DispatchQueue.main.async {
                self.hasSetInitialCamera = true
            }
        }

        for room in roomLocations {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: room.latitude, longitude: room.longitude)
            marker.title = room.name
            marker.snippet = "Owned by: \(room.teamOwner ?? "unclaimed")"

            switch room.teamOwner {
            case "Grey":
                if let image = UIImage(named: "GreyMarker") {
                    marker.icon = resizeImage(image: image, targetSize: CGSize(width: 40, height: 40))
                }
            case "Blue":
                if let image = UIImage(named: "BlueMarker") {
                    marker.icon = resizeImage(image: image, targetSize: CGSize(width: 40, height: 40))
                }
            case "Pink":
                if let image = UIImage(named: "PinkMarker") {
                    marker.icon = resizeImage(image: image, targetSize: CGSize(width: 40, height: 40))
                }
            default:
                marker.icon = GMSMarker.markerImage(with: .red)
            }

            marker.map = uiView
        }
    }
}



// nfc setup
class NFCScanner: NSObject, NFCNDEFReaderSessionDelegate{
    var session: NFCNDEFReaderSession?
    
    
    func beginScanning(completion: @escaping (String) -> Void) {
        guard NFCNDEFReaderSession.readingAvailable else {
            completion("NFC reading not available on this device")
            return
        }
        
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Hold your device near the rooms NFC tag"
        session?.begin()
        
        self.scanCompletion = completion
    }
    
    
    private var scanCompletion: ((String) -> Void)?
    
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for record in message.records {
                if let rawString = String(data: record.payload, encoding: .utf8) {
                    print("scanned data: \(rawString)")
                    parseNFCData(rawString) {message in
                        self.scanCompletion?(message)
                    }
                }
            }
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: any Error) {
        print("NFC scanning failed: \(error.localizedDescription)")
    }
    
    
    private func parseNFCData(_ rawData:String, completion: @escaping (String) -> Void){ // nfc data manipulation
        let cleanedData = rawData.filter { $0.isASCII && $0.isLetter || $0.isNumber || $0 == "=" || $0 == ";" } // clearing hidden data on tag text
        let sanitizedData = cleanedData.replacingOccurrences(of: "en", with: "") // remove language encoding
        let keyValuePairs = sanitizedData.split(separator: ";") // split data if there is a semicolon used for testing multiple data
        var parsedData: [String: String] = [:]
        
        for pair in keyValuePairs {
            let components = pair.split(separator: "=", maxSplits: 1)
            if components.count == 2 {
                let key = String(components[0]).trimmingCharacters(in: .whitespacesAndNewlines)
                let value = String(components[1]).trimmingCharacters(in: .whitespacesAndNewlines)
                parsedData[key] = value
            }
        }
        
        guard let roomName = parsedData["room"] else{
            print("NFC Data incorect room not found")
            return
        }
        
        let db = Firestore.firestore()
        let roomRef = db.collection("Rooms").document(roomName)
        roomRef.getDocument { document, error in
            if let error = error {
                print("Error fetching room doc: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists else {
                print("Room \(roomName) not found in firestore")
                return
            }
            
            guard let user = Auth.auth().currentUser,
                  let username = UserLocal.currentUser?.username,
                  let team = UserLocal.currentUser?.team else {
                print("User not authed or missing data")
                return
            }
            
            roomRef.updateData([
                "userowner": username,
                "teamowner": team,
            ]) { error in
                if let error = error {
                    print("Failed to update room: \(error.localizedDescription)")
                    completion("Failed to claim room")
                } else {
                    print("Room successfully updated")
                    completion("Successfully claimed \(roomName) for \(team)")
                }
            }
        }
    }
}





// Acutal page below this

struct Maps: View {
    @State private var userLocation: CLLocationCoordinate2D? = nil
    @State private var scanner = NFCScanner()
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var roomLocations: [RoomLocation] = []
    @State private var hasSetInitialCamera = false
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                // Map Section
                GoogleMapView(userLocation: $userLocation, roomLocations: $roomLocations, hasSetInitialCamera: $hasSetInitialCamera)
                    .edgesIgnoringSafeArea([.top, .leading, .trailing])
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.background)

                // Scan Room Button
                Button(action: {
                    scanner.beginScanning { message in
                        self.alertMessage = message
                        self.showAlert = true
                    }
                }){
                    Image(systemName: "dot.radiowaves.up.forward")
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.actionColour)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        .padding(.top, 10)
                        .padding(.trailing, 10)
                }
            }
            .background(Color.background.ignoresSafeArea())
            .alert(isPresented: $showAlert){
                Alert(title: Text("Room Capture"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear{
                startListeningForRoomUpdates()
            }
        }
    }
    func startListeningForRoomUpdates() {
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
                    
                    let teamOwner = data["teamowner"] as? String ?? "unclaimed"
                    
                    let room = RoomLocation(
                        id: doc.documentID,
                        name: name,
                        latitude: latitude,
                        longitude: longitude,
                        teamOwner: teamOwner
                    )
                    
                    locations.append(room)
                } else {
                    print("Skipping invalid document: \(doc.documentID)")
                }
            }
            
            DispatchQueue.main.async {
                self.roomLocations = locations
            }
        }
    }
}

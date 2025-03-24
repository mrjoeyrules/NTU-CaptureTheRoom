//
//  GoogleMaps.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 07/03/2025.
//

import SwiftUI
import CoreLocation // Location tracking
import FirebaseAuth // firebase authentication
import FirebaseCore // base firebase
import FirebaseFirestore // firestore
import Foundation
import GoogleMaps // google maps
import SwiftUI

// room location setup


// struct to store info about the rooms for marker use
struct RoomLocation: Identifiable {
    var id: String
    var name: String
    var latitude: Double
    var longitude: Double
    var teamOwner: String?
}

// google maps setup and tracking

struct GoogleMapView: UIViewRepresentable {
    @Binding var userLocation: CLLocationCoordinate2D? // the user current location
    @Binding var roomLocations: [RoomLocation] // array of roomlocations
    @Binding var hasSetInitialCamera: Bool
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var settings = MapSettings() // map settings

    let mapView = GMSMapView() // initialises the map view
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size // gets the passed images size

        let widthRatio = targetSize.width / size.width // gets the width ratio based on target and image width
        let heightRatio = targetSize.height / size.height // same but height

        // Preserve aspect ratio of image being used
        let scaleFactor = min(widthRatio, heightRatio)

        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor) // sets the new suze based on the target sizes and and the aspect ratio
        let renderer = UIGraphicsImageRenderer(size: newSize) // creates a renderer using the new suze

        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize)) // draws the new image with the new size and returns it
        }
    }

    // coordinator class to handle clllocationmanager delgate functions
    class Coordinator: NSObject, CLLocationManagerDelegate {
        var parent: GoogleMapView
        var locationManager: CLLocationManager?
        var mapView: GMSMapView?

        init(parent: GoogleMapView) {
            self.parent = parent
            super.init()
            setupLocationManager()
        }

        private func setupLocationManager() { // SETUP the location manager
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest // set accuracy to best level of accuract
            locationManager?.requestWhenInUseAuthorization() // request location perms
            locationManager?.startUpdatingLocation() // start updating location as in users current location
        }

        
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { // this runs when the users location is updated
            guard let location = locations.last else { return }
            parent.userLocation = location.coordinate

            if let mapView = mapView, parent.userLocation != nil {
                if !parent.hasSetInitialCamera {
                    // moves camera to users location on first update. When the map is first loaded.
                    let cameraUpdate = GMSCameraUpdate.setTarget(location.coordinate, zoom: 17.5) // if userlocation is not nil then on display default to user location
                    mapView.moveCamera(cameraUpdate)
                    DispatchQueue.main.async {
                        self.parent.hasSetInitialCamera = true
                    }
                }
            }
        }

        func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) { // error if getting user location fails
            print("Location Manager error \(error.localizedDescription)")
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> GMSMapView {
        let mapView = GMSMapView(frame: .zero) // actually creates the map view
        mapView.isMyLocationEnabled = true // enables user tracking on the map
        mapView.settings.myLocationButton = true // adds reset location button
        context.coordinator.mapView = mapView // links map view to coordinator
        return mapView
    }
    
    func applyMapStyle(to mapView: GMSMapView){ // code for maptheme selection and display
        let themeToUse = settings.selectedTheme == .systemDefault // gets theme from the settings class if equals systemdefault go between light and dark depending
        ? (colorScheme == .dark ? MapTheme.dark : MapTheme.light) //
        : settings.selectedTheme
        var styleName: String?
        
        switch themeToUse { // different modes depending on the json names
        case .dark:
            styleName = "darkmode"
        case .light:
            styleName = "light"
        case .night:
            styleName = "nightmode"
        case .aubergine:
            styleName = "aubergine"
        case .systemDefault:
            break
        }
        
        if let styleName = styleName, let styleURL = Bundle.main.url(forResource: styleName, withExtension: "json"){ // find json files in root using style name and .json
            do{
                mapView.mapType = .normal // map type to normal
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL) // try set map style to contents of file passed through
            } catch{
                print("Error loading map style: \(error)")
            }
        }else{
            print("map style file not found")
        }
    }
        

    func updateUIView(_ uiView: GMSMapView, context: Context) { // updates map ui view
        applyMapStyle(to: uiView)
        
        if let userLocation = userLocation, !hasSetInitialCamera {
            let cameraUpdate = GMSCameraUpdate.setTarget(userLocation, zoom: 17.5) // sets camera to users location at 17.5 zoom
            uiView.moveCamera(cameraUpdate) // move the camera with the users on the locaiton of camera update
            DispatchQueue.main.async {
                self.hasSetInitialCamera = true
            }
        }
        
        uiView.clear() // Removes all current markers and overlays from the map


        for room in roomLocations { // code from Google Maps Platform DOCS - https://developers.google.com/maps/documentation/ios-sdk/map-with-marker?_gl=1*morkne*_up*MQ..*_ga*NjQwODkxNjE5LjE3NDE3ODM4Njk.*_ga_NRWSTWS78N*MTc0MTc4Mzg2OC4xLjAuMTc0MTc4Mzg3MS4wLjAuMA..
            
            
            let marker = GMSMarker() // creates an instance of GMSMarker
            marker.position = CLLocationCoordinate2D(latitude: room.latitude, longitude: room.longitude) // gets marker position based on room lat and lon
            marker.title = room.name // sets the marker title to the room name
            marker.snippet = "Owned by: \(room.teamOwner ?? "unclaimed")" // changes the marker snippet to be a team owner text

            switch room.teamOwner { // if the team owner is any of the teams use the creates pin icon
            case "Grey":
                if let image = UIImage(named: "GreyMarker") {
                    marker.icon = resizeImage(image: image, targetSize: CGSize(width: 40, height: 40))
                }
            case "Blue":
                if let image = UIImage(named: "BlueMarker") { // selects the correct image from assets
                    marker.icon = resizeImage(image: image, targetSize: CGSize(width: 40, height: 40))
                }
            case "Pink":
                if let image = UIImage(named: "PinkMarker") {
                    marker.icon = resizeImage(image: image, targetSize: CGSize(width: 40, height: 40)) // resize the image to be a normal size
                }
            default:
                marker.icon = GMSMarker.markerImage(with: .red) // if no team default to red
            }

            marker.map = uiView // ui view is GMSMapView push markers to map.
        }
    }
}

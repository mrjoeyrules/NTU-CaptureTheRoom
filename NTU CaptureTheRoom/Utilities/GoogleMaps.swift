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
                    let cameraUpdate = GMSCameraUpdate.setTarget(location.coordinate, zoom: 17.5) // if userlocation is not nil then on display default to user location
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
        if let userLocation = userLocation, !hasSetInitialCamera {
            let cameraUpdate = GMSCameraUpdate.setTarget(userLocation, zoom: 17.5)
            uiView.moveCamera(cameraUpdate)
            DispatchQueue.main.async {
                self.hasSetInitialCamera = true
            }
        }

        for room in roomLocations {
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

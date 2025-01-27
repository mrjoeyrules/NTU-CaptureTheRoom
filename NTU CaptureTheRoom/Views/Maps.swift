//
//  Maps.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 02/12/2024.
//

import CoreLocation
import FirebaseCore
import FirebaseFirestore
import Foundation
import GoogleMaps
import SwiftUI

// google maps setup and tracking

struct GoogleMapView: UIViewRepresentable {
    @Binding var userLocation: CLLocationCoordinate2D?

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
                let cameraUpdate = GMSCameraUpdate.setTarget(location.coordinate, zoom: 15) // if userlocation is not nil then on display default to user location
                mapView.animate(with: cameraUpdate)
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
        if let userLocation = userLocation {
            let cameraUpadate = GMSCameraUpdate.setTarget(userLocation, zoom: 15)
            uiView.animate(with: cameraUpadate)
        }
    }
}

// Acutal page below this

struct Maps: View {
    @State private var userLocation: CLLocationCoordinate2D? = nil
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                // Map Section
                GoogleMapView(userLocation: $userLocation)
                    .edgesIgnoringSafeArea([.top, .leading, .trailing])
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.background)

                // Scan Room Button
                NavigationLink(destination: ScanRoom()) {
                    Image(systemName: "dot.radiowaves.up.forward")
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.actionColour)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .padding(.top, 10)
                .padding(.trailing, 10)
            }
            .background(Color.background.ignoresSafeArea())
        }
    }
}

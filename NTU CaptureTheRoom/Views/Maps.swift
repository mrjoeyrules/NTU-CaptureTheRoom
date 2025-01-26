//
//  Maps.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 02/12/2024.
//

import FirebaseCore
import FirebaseFirestore
import Foundation
import GoogleMaps
import SwiftUI

struct GoogleMapView: UIViewRepresentable {
    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: 37.3317, longitude: -122.0317, zoom: 10)
        let mapView = GMSMapView(frame: .zero, camera: camera)
        return mapView
    }

    func updateUIView(_ uiView: GMSMapView, context: Context) {
    }
}

struct Maps: View {
    var body: some View {
        GoogleMapView()
            .edgesIgnoringSafeArea([.top, .leading, .trailing]) // Ignore safe area except bottom
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color.background
                    .ignoresSafeArea(edges: [.top, .leading, .trailing]) // Same as above
            }
    }
}

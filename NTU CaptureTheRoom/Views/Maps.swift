//
//  Maps.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 02/12/2024.
//

import Foundation
import SwiftUI
import FirebaseCore
import GoogleMaps
import FirebaseFirestore

struct GoogleMapView: UIViewRepresentable{
    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: 37.3317, longitude: -122.0317, zoom: 10)
        let mapView = GMSMapView(frame: .zero, camera: camera)
        return mapView
    }
    func updateUIView(_ uiView: GMSMapView, context: Context) {
            
    }
}


struct Maps: View{
    var body: some View{
        GoogleMapView()
            .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    Maps()
}

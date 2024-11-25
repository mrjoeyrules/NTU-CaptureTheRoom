//
//  NTU_CaptureTheRoomApp.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 25/11/2024.
//

import SwiftUI
import SwiftData
import FirebaseCore
import GoogleMaps

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}


@main
struct NTU_CaptureTheRoomApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    init(){
        GMSServices.provideAPIKey("AIzaSyAoV5ll67vmKdZOjFgQ-C7Lo2zszVyuO_k")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

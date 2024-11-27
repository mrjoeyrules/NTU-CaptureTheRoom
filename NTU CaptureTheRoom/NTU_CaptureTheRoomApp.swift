//
//  NTU_CaptureTheRoomApp.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 25/11/2024.
// maps API Key - AIzaSyAf-EIBS2MDCudvg-QyYmOKmsmRNYj1gGA

import SwiftUI
import SwiftData
import FirebaseCore
import GoogleMaps
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
}


@main
struct NTU_CaptureTheRoomApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    init(){
        GMSServices.provideAPIKey("AIzaSyAf-EIBS2MDCudvg-QyYmOKmsmRNYj1gGA")
    }
    
    

    var body: some Scene {
        WindowGroup {
            Registration()
        }
    }
}

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
import FirebaseAuth
import FirebaseAppCheck


@main
struct NTU_CaptureTheRoomApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var Delegate
    @StateObject private var appState = AppState()
    init(){
        
        configApp()
    }
    
    

    var body: some Scene {
        WindowGroup {
            if appState.isLoggedIn == nil{
                CustomProgressView()
            } else if appState.isLoggedIn == true{
                Tabs(selectedTab: .maps)
            }else{
                Registration()
            }
        }
    }
    
    private func configApp(){
        if FirebaseApp.app() == nil{
            FirebaseApp.configure()
            GMSServices.provideAPIKey("AIzaSyAf-EIBS2MDCudvg-QyYmOKmsmRNYj1gGA")
        }
    }
    
    
}

class AppDelegate : NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:
                     [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool{
        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
        return true
    }
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

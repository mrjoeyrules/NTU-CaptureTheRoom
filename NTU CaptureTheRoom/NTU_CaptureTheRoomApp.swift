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
import FirebaseFirestore
import FirebaseMessaging
import UserNotifications


@main
struct NTU_CaptureTheRoomApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var Delegate
    @StateObject private var appState = AppState()
    init(){
        configApp()
    }
    
    

    var body: some Scene {
        WindowGroup {
            if appState.isLoggedIn == nil{ // play loading screen if taking a while to check log in sate
                CustomProgressView()
            } else if appState.isLoggedIn == true{
                Tabs(selectedTab: .maps) // if is logged in is true go to maps
            }else{
                Registration() // else go to registration
            }
        }
    }
    
    private func configApp(){
        if FirebaseApp.app() == nil{
            FirebaseApp.configure() // config info, maps and firebase
            GMSServices.provideAPIKey("AIzaSyAf-EIBS2MDCudvg-QyYmOKmsmRNYj1gGA")
        }
    }
    
    
    
    
}

class AppDelegate : NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:
                     [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool{
        //configMessaging(application)
        return true
    }

    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let incomingURL = userActivity.webpageURL {
            // Handle the Firebase Auth URL
            let handled = Auth.auth().canHandle(incomingURL)
            return handled
        }
        return false
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if Auth.auth().canHandle(url) {
            return true
        }
        return false
    }
    
    /*
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token{ token, error in
            if let error = error{
                print("error fetching fcm token: \(error.localizedDescription)")
            }else if let token = token{
                print("fetched fcm: \(token)")
                UserDefaults.standard.set(token, forKey: "fcmToken")
                UserDefaults.standard.synchronize()
            }
        }
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
            print("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    func configMessaging(_ application: UIApplication){ // configures the messaging
        registerForPushNotis(application)
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
    }
    
    
    
    func registerForPushNotis(_ application: UIApplication){ // auth and permissions from user
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            if granted{
                print("push notis enabled")
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }else{
                print("push notis permission denied")
            }
        }
    }
    // I would use APNs but uni apple dev acc doesnt have access to keys to create the key and i dont have 100£ to buy my own one.
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?){
        guard let token = fcmToken else {return}
        print("fcmtoken : \(String(describing: fcmToken))") // testing
        UserDefaults.standard.set(fcmToken, forKey: "fcmToken") // store temp becuase what if user not signed in/no account created
        UserDefaults.standard.synchronize()
            
        if Auth.auth().currentUser != nil{
            saveFCMToFS(token: token)
        }
    }
     
     
    
    func saveFCMToFS(token: String){
        guard let user = Auth.auth().currentUser else {return}
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).updateData(["fcmToken": token]){ error in
            if let error = error{
                print("Failed to save fcm: \(error.localizedDescription)")
            }else{
                print("FCM saved")
            }
        }
    }
     */
}

//
//  AppState.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 08/03/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging
class AppState: ObservableObject{
    @Published var isLoggedIn: Bool? = nil
    
    init(){
        Task{
            await checkUserAuthState()
        }
    }
    
    @MainActor //  Ensures updates happen on the main thread
    func checkUserAuthState() async {
        let user = Auth.auth().currentUser
        if let user = user { // If user is logged in
            print("User is logged in: \(user.uid)")
            self.isLoggedIn = true
        } else {
            print("No user logged in")
            self.isLoggedIn = false
        }
    }
    /*
    @MainActor //  Ensures updates happen on the main thread
    func checkUserAuthState() {

        Task { //  Runs asynchronously in a safe manner
            let user = Auth.auth().currentUser
            
            if let user = user { // if user contains info then a user is logged in, Set flag to true
                print("User is logged in: \(user.uid)")
                
                let fcmToken = UserDefaults.standard.string(forKey: "fcmToken") ?? ""
                if !fcmToken.isEmpty {
                    let db = Firestore.firestore()
                    db.collection("users").document(user.uid).setData(["fcmToken": fcmToken], merge: true)
                }
                updateFCMToken()
                isLoggedIn = true
            } else {
                print("No user logged in")
                isLoggedIn = false
            }
        }
    }
     */ // would work if APNS were enabled thanks ntu
    
    func updateFCMToken(){
        
        guard let _ = Messaging.messaging().apnsToken else{
            print("APNs token not available yet")
            return
        }
        
        
        Messaging.messaging().token{ token, error in
            if let error = error{
                print("Error fetching fcm: \(error.localizedDescription)")
            }else if let token = token{
                print("fetched fcm: \(token)")
                UserDefaults.standard.set(token, forKey: "fcmToken")
                UserDefaults.standard.synchronize()
                self.saveFCMToFS(token: token)
            }
        }
    }
    
    private func saveFCMToFS(token: String){
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).setData(["fcmToken": token]) { error in
            if let error = error{
                print("failed to save fcm: \(error.localizedDescription)")
            }else{
                print("saved token to fs")
            }
        }
    }
}



//
//  AppState.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 08/03/2025.
//

import SwiftUI
import FirebaseAuth

class AppState: ObservableObject{
    @Published var isLoggedIn: Bool? = nil
    
    init(){
        Task { await checkUserAuthState() }
    }
    
    @MainActor //  Ensures updates happen on the main thread
    func checkUserAuthState() {
        print("Checking user authentication state...") // Debug log

        Task { //  Runs asynchronously in a safe manner
            let user = Auth.auth().currentUser
            
            if let user = user {
                print("User is logged in: \(user.uid)")
                isLoggedIn = true
            } else {
                print("No user logged in")
                isLoggedIn = false
            }
        }
    }
}



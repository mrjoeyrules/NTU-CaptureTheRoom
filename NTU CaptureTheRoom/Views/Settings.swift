//
//  Settings.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 03/02/2025.
//

import SwiftUI
import FirebaseAuth

struct Settings: View {
    @State private var isSignedOut: Bool = false
    func signOut(){
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            UserLocal.currentUser?.user = nil
            UserLocal.currentUser?.username = ""
            UserLocal.currentUser?.team = ""
            UserLocal.currentUser?.level = 0
            UserLocal.currentUser?.xp = 0
            UserLocal.currentUser?.setUpStatus = ""
            isSignedOut = true
            
            
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    
    
    var body: some View {
        if isSignedOut == true{
            Login()
        }
        else{
            VStack{
                ZStack{
                    Text("Settings page")
                }
                ZStack{
                    Button(action: signOut){
                        Text("Sign Out")
                            .padding()
                            .foregroundStyle(Color.white)
                            .background(
                                RoundedRectangle(
                                    cornerRadius: 20, style: .continuous)
                                .fill(.actionColour))
                    }
                }
            }
            .navigationBarBackButtonHidden(false)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color.background
                    .ignoresSafeArea()
            }
        }
    }
}

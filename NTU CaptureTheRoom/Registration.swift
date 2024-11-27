//
//  Registration.swift
//  NTU CaptureTheRoom
//
// Google Client ID - 1087587490413-h3lgag365jha4nm1vamnfhebngs1ca8k.apps.googleusercontent.com

// GOOGLE - 1087587490413-h3lgag365jha4nm1vamnfhebngs1ca8k.apps.googleusercontent.com
//  Created by Joseph Cuesta Acevedo on 25/11/2024.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

enum ActiveAlert{ // set cases for the active alert
    case first, second
}

struct Registration: View{
    
    // variables for various uses within page.
    @State var email: String = "" // inputed email
    @State var password: String = "" // inputed password
    @State var confirmPassword: String = "" // password re-entered
    @State var showAlert: Bool = false // show alert flag
    @State var activeAlert: ActiveAlert = .first // which alert flag
    let logo = "NTUShieldLogo" // name of logo picture
    
    
    
    
    
    func Register(){ // runs code when register button is pressed
        self.showAlert = false
        if password != confirmPassword{ // if passwords dont match flag as invalid
            self.activeAlert = .first
            self.showAlert = true
            
        }
        else{
            
            Auth.auth().createUser(withEmail: email, password: password) { result, error in        } // creates a user in firebase authentication with email and password entered.
            self.activeAlert = .second
            self.showAlert = true
            // creates a user with email and password in firebase auth
        }
    }
    
    func RegisterWithGoogle(){
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }
        
        
        GIDSignin.sharedInstance.configuration = config
        GIDSignin.sharedInstance.signIn(withPresenting: rootVC) {result , error in
            guard error == nil else{
                print("Sign in error: \(error!.localizedDescription)")
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else { print("Failed to retrieve user or ID token")
                return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            
            
            Auth.auth().signIn(with: credential) {authResult, error in
                if let error = error{
                    print("Firebase register error: \(error.localizedDescription)")
                } else{
                    print("User registered successfully: \(authResult?.user.displayName ?? "Unknown user")")
                }
                if let isNewUser = authResult?.additionalUserInfo?.isNewUser, isNewUser{
                    print("New user registered: \(authResult?.user.email ?? "Unknown email")")
                }else{
                    print("Existing user logged in: \(authResult?.user.email ?? "Unknown email")")
                }
            }
            
        
    }
    
    
        var body: some View{
            NavigationStack{
                VStack{
                    Image(logo)
                        .resizable()
                        .frame(width: 150 , height: 150)
                        .padding()
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.actionColour) // Background color matches the rectangle
                            .frame(height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.actionColour, lineWidth: 1) // Border color
                            )
                        TextField("Email", text: $email)
                            .autocapitalization(.none)
                            .foregroundColor(.white) // Text color
                            .padding(.horizontal) // Padding inside the text field
                            .frame(height: 50)
                    }
                    .padding(.horizontal) // Outer padding
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.actionColour) // Background color matches the rectangle
                            .frame(height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.actionColour, lineWidth: 1) // Border color
                            )
                        SecureField("Password", text: $password)
                            .autocapitalization(.none)
                            .foregroundColor(.white) // Text color
                            .padding(.horizontal) // Padding inside the text field
                            .frame(height: 50)
                    }
                    .padding(.horizontal) // Outer padding
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.actionColour) // Background color matches the rectangle
                            .frame(height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.actionColour, lineWidth: 1) // Border color
                            )
                        SecureField("Confirm Password", text: $confirmPassword)
                            .autocapitalization(.none)
                            .foregroundColor(.white) // Text color
                            .padding(.horizontal)// Padding inside the text field
                            .frame(height: 50)
                    }
                    .padding(.horizontal) // Outer padding
                    
                    ZStack{
                        Button(action: Register){
                            Text("Register")
                                .padding()
                                .background(Color.actionColour)
                                .foregroundStyle(Color.textColour)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.actionColour)
                                )
                            
                                .alert(isPresented: $showAlert){
                                    switch activeAlert {
                                    case .first:
                                        return Alert(title: Text("Passwords do not match"), message: Text("Ensure that your passwords match"), dismissButton: .default(Text("Try Again")))
                                    case .second:
                                        return Alert(title: Text("Account Created"), message: Text("Your account has been created"), dismissButton: .default(Text("Continue")))
                                    } // code found from https://stackoverflow.com/questions/58069516/how-can-i-have-two-alerts-on-one-view-in-swiftui
                                    //User John M
                                    
                                }
                            // Alert code is needed to display to different alerts based on one button.
                        }
                    }
                    
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background{
                    Color.background
                        .ignoresSafeArea()
                }
            }
        }
    }
}
#Preview {
    Registration()
}

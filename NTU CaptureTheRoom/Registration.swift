//
//  Registration.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 25/11/2024.
//

import Foundation
import SwiftUI
import FirebaseAuth

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
    
    func register(){ // runs code when register button is pressed
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
    
    
    var body: some View{
        NavigationStack{
            VStack{
                Image(logo)
                    .padding()
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .padding()
                // Disabled auto caps - no one wnats auto caps on an email its annoying
                SecureField("Password", text: $password)
                    .textContentType(.username)
                    .autocapitalization(.none)
                    .padding()
                // disabled auto caps and strong password reminder view, very annoying
                SecureField("Confirm Password", text: $confirmPassword)
                    .textContentType(.username)
                    .autocapitalization(.none)
                    .padding()
                Button(action: register){
                    Text("Register")
                        .padding()
                    
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
    }
}
#Preview {
    Registration()
}

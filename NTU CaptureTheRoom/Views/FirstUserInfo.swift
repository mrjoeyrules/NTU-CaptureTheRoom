//
//  FirstUserInfo.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 20/01/2025.
//

// this is where user sets username
import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import SwiftUI
import SwiftData

enum ActiveAlert4{ // set cases for the active alert
    case first, second, third
}

struct FirstUserInfo: View{
    @State var activeAlert: ActiveAlert4 = .first
    @State var showAlert: Bool = false
    
    @State var username: String = ""
    @State var usernameAccepted: Bool = false

    // checks is username is available
    func isUsernameAvailable(username: String, completion: @escaping (Bool, Error?) -> Void){
        let db = Firestore.firestore() // get FS
        // check users collection where the username field is equal to users entered username and get the doc
        db.collection("users").whereField("username", isEqualTo: username).getDocuments { snapshot, error in
            if let error = error{
                completion(false, error) // if error return false and the error for the alert
                return
            }
            if let snapshot = snapshot, snapshot.documents.isEmpty{ // if document is empty meaning couldnt find doc then return that username is available
                completion(true, nil)
            }else{ // username not available
                completion(false, nil)
            }
        }
    }
    
    func updateUsername(username: String, completion: @escaping (Error?) -> Void){ // updates the username in FS
        guard let uid = Auth.auth().currentUser?.uid else { // get user auth
            print("No authenticated user.")
            completion(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(uid).updateData([ // users collection with doc name of users uid. update the data in the username field with the parsed username
            "username": username
        ]) { error in
            if let error = error{ // if error print error
                print(error.localizedDescription)
                completion(error) // return error
            }else{
                UserLocal.currentUser?.username = username // set current user username in userlocal class
                completion(nil)
            }
        }
    }
    
    func SubmitUsername(){ // this runs when user presses button to submit username
        guard !username.isEmpty else { // if field is empty show alert third which is username must not be empty
            self.activeAlert = .third
            self.showAlert = true
            return
        }
        isUsernameAvailable(username: username) { isAvailable, error in // checks if username is available first
            if let error = error {
                print("Failed to check username availability: \(error.localizedDescription)")
                return
            }
            
            if isAvailable { // if available
                // Proceed to update Firestore with the username
                updateUsername(username: username) { error in // update username
                    if error != nil { // if an error
                        self.activeAlert = .first
                        self.showAlert = true
                    } else {
                        // if all good set alert to success
                        usernameAccepted = true // set username accepted flag to true
                        self.activeAlert = .second
                        self.showAlert = true
                    }
                }
            } else {
                self.activeAlert = .first
                self.showAlert = true
            }
        }
    }
    
    
    var body: some View{
        NavigationStack{
            if(usernameAccepted){
                TeamSelection() // is usernameAccepted flag is true go to team selection instead of this page
            }else{
                VStack{
                    ZStack{
                        Text("Enter a Username please!")
                            .padding() // welcome text
                            .foregroundStyle(Color.white)
                            .multilineTextAlignment(.center)
                    }
                    ZStack{
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white) // Background color matches the rectangle
                            .frame(height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20) // creates a rectangle to cover and match the text field
                                    .stroke(Color.actionColour, lineWidth: 1) // Border color
                            )
                        TextField("",text: $username, prompt: Text("Username").foregroundStyle(Color.black.opacity(0.5))) // email text field
                            .autocapitalization(.none)
                            .textContentType(.emailAddress)
                            .foregroundColor(.black) // Text color
                            .padding(.horizontal) // Padding inside the text field
                            .frame(height: 50)
                    }
                    .padding(.horizontal) // Outer padding
                    ZStack{
                        Button(action:SubmitUsername){
                            Text("Enter")
                                .padding()
                                .foregroundStyle(Color.white)
                                .background(
                                    RoundedRectangle(
                                        cornerRadius: 20, style: .continuous)
                                    .fill(.actionColour))
                                .alert(isPresented: $showAlert){ //different alerts that can pop up when registering
                                    switch activeAlert {
                                    case .first:
                                        return Alert(title: Text("Username already in use"), message: Text("This username is already in use, please try again"), dismissButton: .default(Text("Try Again")))
                                    case .second:
                                        return Alert(title: Text("Account Created"), message: Text("Username accepted"), dismissButton: .default(Text("Continue")))
                                    case .third:
                                        return Alert(title: Text("Enter a username"), message: Text("You did not enter a username, please enter a username"), dismissButton: .default(Text("Try Again")))
                                    }
                                }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background{
                    Color.background // sets background to background colour
                        .ignoresSafeArea()
                }
            }
        }
    }
}

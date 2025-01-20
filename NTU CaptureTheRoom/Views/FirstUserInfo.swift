//
//  FirstUserInfo.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 20/01/2025.
//

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

    func isUsernameAvailable(username: String, completion: @escaping (Bool, Error?) -> Void){
        let db = Firestore.firestore()
        db.collection("users").whereField("username", isEqualTo: username).getDocuments { snapshot, error in
            if let error = error{
                completion(false, error)
                return
            }
            if let snapshot = snapshot, snapshot.documents.isEmpty{
                completion(true, nil)
            }else{
                completion(false, nil)
            }
        }
    }
    
    func updateUsername(username: String, completion: @escaping (Error?) -> Void){
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No authenticated user.")
            completion(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(uid).updateData([
            "username": username
        ]) { error in
            if let error = error{
                print(error.localizedDescription)
                completion(error)
            }else{
                completion(nil)
            }
        }
    }
    
    func SubmitUsername(){
        guard !username.isEmpty else {
            self.activeAlert = .third
            self.showAlert = true
            return
        }
        isUsernameAvailable(username: username) { isAvailable, error in
            if let error = error {
                print("Failed to check username availability: \(error.localizedDescription)")
                return
            }
            
            if isAvailable {
                // Proceed to update Firestore with the username
                updateUsername(username: username) { error in
                    if let error = error {
                        self.activeAlert = .first
                        self.showAlert = true
                    } else {
                        // if all good set alert to success
                        usernameAccepted = true
                        let loggedInUser = UserLocal(username: username)
                        UserLocal.currentUser = loggedInUser
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
                TeamSelection()
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
                    Color.background
                        .ignoresSafeArea()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

//
//  Login.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 25/11/2024.
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseAuth

struct Login: View {
    @State var email: String = ""
    @State var password: String = ""
    @State private var isLoggedIn = false
    
    func login(){
        Auth.auth().signIn(withEmail: email, password: password){ (result, error) in
            if error != nil{
                print(error?.localizedDescription ?? "")
            }else{
                print("success")
                isLoggedIn = true
            }
        }
    }
    
    var body: some View {
        NavigationStack{
            
            
            VStack{
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                SecureField("Password", text: $password)
                Button(action: {login()}){
                    Text("Sign in")
                }
            }
            .padding()
        }
    }
}

#Preview {
    Login()
}

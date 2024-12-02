//
//  ForgotPassword.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 02/12/2024.
//

import Foundation
import FirebaseAuth
import SwiftUI

struct ForgotPassword: View {
    @State var email: String = ""
    @State var error: Error?
    
    
    func sendReset(){
        Auth.auth().sendPasswordReset(withEmail: email){error in
            if error != nil{
                print(error!.localizedDescription)
            }
        }
    }
    
    
    var body: some View {
        VStack{
            ZStack{
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
            }
            ZStack{
                Button(action: sendReset){ // button to register an email account
                    Text("Reset Password")
                        .padding()
                        .foregroundStyle(Color.white)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 20, style: .continuous)
                            .fill(.actionColour))
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

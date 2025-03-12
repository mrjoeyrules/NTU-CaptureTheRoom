//
//  ForgotPassword.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 02/12/2024.
//

import Foundation
import FirebaseAuth
import SwiftUI

enum ActiveAlert3{
    case first, second, third
    
}

struct ForgotPassword: View { // forogt password page. User enters email and sends reset email
    @State var email: String = ""
    @State var showAlert: Bool = false // show alert flag
    @State var error: Error?
    @State var activeAlert: ActiveAlert3 = .first // which alert flag
    @State var isComplete: Bool = false
    let logo = "NTUShieldLogo" // name of logo picture
    
    
    func sendReset(){
        Auth.auth().sendPasswordReset(withEmail: email){error in
            if let error = error{
                if let errorCode = AuthErrorCode(rawValue: error._code){
                    switch errorCode{
                    case .invalidEmail: // if email is invalid show alert
                        self.activeAlert = .first
                    default:
                        self.activeAlert = .third // if any other error show default error msg
                    }
                }
            }else{
                self.activeAlert = .second // if no error display show success alert
            }
            self.showAlert.toggle() // set showalert to true
        }
    }
    
    
    var body: some View {
            VStack{
                Image(logo) // ntu logo at top
                    .resizable()
                    .frame(width: 100 , height: 100)
                    .padding()
                ZStack{
                    Text("Forgot your Password? \n Enter your email to send a reset link")
                        .padding() // welcome text
                        .foregroundStyle(Color.white)
                        .multilineTextAlignment(.center)
                }
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white) // Background color matches the rectangle
                        .frame(height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20) // creates a rectangle to cover and match the text field
                                .stroke(Color.actionColour, lineWidth: 1) // Border color
                        )
                    TextField("",text: $email, prompt: Text("Email").foregroundStyle(Color.black.opacity(0.5))) // email text field
                        .autocapitalization(.none)
                        .textContentType(.emailAddress)
                        .foregroundColor(.black) // Text color
                        .padding(.horizontal) // Padding inside the text field
                        .frame(height: 50)
                    
                }
                .padding(.horizontal) // Outer padding
                ZStack{
                    Button(action: sendReset){ // button to register an email account
                        Text("Reset Password")
                            .padding()
                            .foregroundStyle(Color.white)
                            .background(
                                RoundedRectangle(
                                    cornerRadius: 20, style: .continuous)
                                .fill(.actionColour)) // set password reset button to action colour
                            .alert(isPresented: $showAlert){ // if showalert is true show one of these
                                switch activeAlert {
                                case .first:
                                    return Alert( // different alerts for possible errors
                                        title: Text("Email address is not valid"),
                                        message: Text("Ensure you enter your accounts email address"),
                                        dismissButton: .default(Text("Try Again")))
                                case .second:
                                    return Alert(
                                        title: Text("Password Reset sent"),
                                        message: Text("Check your email for a password reset link"),
                                        dismissButton: .default(Text("OK")))
                                case .third:
                                    return Alert(
                                        title: Text("An error occurred"),
                                        message: Text("Please try again later"),
                                        dismissButton: .default(Text("Try Again")))
                                }
                                
                            }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background{
                Color.background // set background
                    .ignoresSafeArea()
            }
        }
}

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
    let twitterProvider = OAuthProvider(providerID: "twitter.com")
    let gitProvider = OAuthProvider(providerID: "github.com")
    
    // variables for various uses within page.
    @State var email: String = "" // inputed email
    @State var password: String = "" // inputed password
    @State var confirmPassword: String = "" // password re-entered
    @State var showAlert: Bool = false // show alert flag
    @State var isGoogleLogIn: Bool = false
    @State var activeAlert: ActiveAlert = .first // which alert flag
    let logo = "NTUShieldLogo" // name of logo picture
    
    func RegisterX(){
        twitterProvider.getCredentialWith(nil){ twitterCredential, error in
            if error != nil{
                print(error?.localizedDescription)
            }
            if twitterCredential != nil{
                Auth.auth().signIn(with: twitterCredential!){ authResult, error in
                    if error != nil{
                        print(error?.localizedDescription)
                    }
                }
            }
            
        }
    }
    func RegisterGithub(){
        print("Register with Github")
        gitProvider.getCredentialWith(nil) { gitCredential, error in
          if error != nil {
              print(error?.localizedDescription)
          }
          if gitCredential != nil {
              Auth.auth().signIn(with: gitCredential!) { authResult, error in
              if error != nil {
                  print(error?.localizedDescription)
              }
              // User is signed in.
              // IdP data available in authResult.additionalUserInfo.profile.

                  guard let oauthCredential = authResult?.credential as? OAuthCredential else { return }
              // GitHub OAuth access token can also be retrieved by:
              // oauthCredential.accessToken
              // GitHub OAuth ID token can be retrieved by calling:
              // oauthCredential.idToken
            }
          }
        }
        
    }
    
    
    
    func RegisterGoogle(){
        guard let clientId = FirebaseApp.app()?.options.clientID else {return}
        
        let config = GIDConfiguration(clientID: clientId)
        
        GIDSignIn.sharedInstance.signIn(withPresenting: ApplicationUtility.rootViewController){
            signResult, err in
            if let error = err{
                print(error.localizedDescription)
                return
            }
            guard let user = signResult?.user,
                  let idToken = user.idToken
            else {
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) {result, error in
                if let err = error{
                    print(err.localizedDescription)
                    return
                }
                guard let user = result?.user else {return}
                print(user.displayName)
                self.isGoogleLogIn.toggle()
            }
        }
        
    }
    
    
    
    
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
    
    
    var body: some View{
        NavigationStack{
            VStack{
                Image(logo)
                    .resizable()
                    .frame(width: 100 , height: 100)
                    .padding()
                ZStack{
                    Text("Welcome to the NTU Capture The Room App \n Please register to use the app")
                        .padding()
                        .foregroundStyle(Color.white)
                        .multilineTextAlignment(.center)
                }
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white) // Background color matches the rectangle
                        .frame(height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.actionColour, lineWidth: 1) // Border color
                        )
                    TextField("",text: $email, prompt: Text("Email").foregroundStyle(Color.black.opacity(0.5)))
                        .autocapitalization(.none)
                        .textContentType(.emailAddress)
                        .foregroundColor(.black) // Text color
                        .padding(.horizontal) // Padding inside the text field
                        .frame(height: 50)
                        
                }
                .padding(.horizontal) // Outer padding
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white) // Background color matches the rectangle
                        .frame(height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.actionColour, lineWidth: 1) // Border color
                        )
                    SecureField("", text: $password, prompt: Text("Password").foregroundStyle(Color.black.opacity(0.5)))
                        .autocapitalization(.none)
                        .textContentType(.name)
                        .foregroundColor(.black) // Text color
                        .padding(.horizontal) // Padding inside the text field
                        .frame(height: 50)
                }
                .padding(.horizontal) // Outer padding
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white) // Background color matches the rectangle
                        .frame(height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.actionColour, lineWidth: 1) // Border color
                        )
                    SecureField("", text: $confirmPassword, prompt: Text("Confirm Password").foregroundStyle(Color.black.opacity(0.5)))
                        .autocapitalization(.none)
                        .textContentType(.name)
                        .foregroundColor(.black) // Text color
                        .padding(.horizontal)// Padding inside the text field
                        .frame(height: 50)
                }
                .padding(.horizontal) // Outer padding
                
                ZStack{
                    Button(action: Register){
                        Text("Register")
                            .padding()
                            .background(Color.actionColour)
                            .foregroundStyle(Color.white)
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
                ZStack{
                    Text("Or Register with one of the following options")
                        .foregroundColor(.white)
                        .padding()
                }
                ZStack{
                    HStack{
                        Button{
                            RegisterGoogle()
                        } label: {
                            VStack{
                                Image("GoogleLogo")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .padding()
                                    .background(Color.googleColour)
                            }
                        }
                        .padding()
                        
                        Button{
                            RegisterX()
                        } label: {
                            VStack{
                                Image("XLogo")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .padding()
                                    .background(Color.black)
                            }
                        }
                        .padding()
                        
                        Button{
                            RegisterGithub()
                        } label: {
                            VStack{
                                Image("GithubLogo")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .padding()
                                    .background(Color.githubColour)
                            }
                        }
                        .padding()
                    }
                }
                ZStack{
                    NavigationLink(destination: Login()){
                        Text("Already have an account?")
                            .foregroundColor(.white)
                            .underline()
                            .padding()
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
#Preview {
    Registration()
}

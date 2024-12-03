//
//  Login.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 25/11/2024.
//

import Foundation
import SwiftUI
import FirebaseCore
import GoogleSignIn
import FirebaseAuth

enum ActiveAlert2{ // set cases for the active alert
    case first, second, third, fourth, fifth, sixth
}


struct Login: View {
    let twitterProvider = OAuthProvider(providerID: "twitter.com")
    let gitProvider = OAuthProvider(providerID: "github.com")
    @State var email: String = ""
    @State var password: String = ""
    @State var showAlert: Bool = false // show alert flag
    @State var isGoogleLogIn: Bool = false
    @State var isGitLogin: Bool = false
    @State var isTwitterLogin: Bool = false
    @State var activeAlert: ActiveAlert2 = .first
    @State  var isLoggedIn: Bool = false
    let logo = "NTUShieldLogo" // name of logo picture
    
    func loginWithGoogle(){
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
                else if error?.localizedDescription == "An account already exists with the same email address but different sign-in credentials. Sign in using a provider associated with this email address."{
                    self.activeAlert = .fourth
                }
                else if error?.localizedDescription == "The user account has been disabled by an administrator."{
                    self.activeAlert = .fifth
                }
                else if error == nil{
                    guard let user = result?.user else {return}
                    print(user.displayName)
                    self.isGoogleLogIn.toggle()
                }
            }
        }
        
    }
    
    func loginWithX(){
        twitterProvider.getCredentialWith(nil){ twitterCredential, error in
            if error != nil{
                print(error?.localizedDescription)
            }
            if twitterCredential != nil{
                Auth.auth().signIn(with: twitterCredential!){ authResult, error in
                    if error != nil{
                        print(error?.localizedDescription)
                    }
                    else if error?.localizedDescription == "An account already exists with the same email address but different sign-in credentials. Sign in using a provider associated with this email address."{
                        self.activeAlert = .fourth
                    }
                    else if error?.localizedDescription == "The user account has been disabled by an administrator."{
                        self.activeAlert = .fifth
                    }
                    else if error == nil{
                        self.isTwitterLogin.toggle()
                    }
                    
                }
                
            }
            
        }
    }
    
    func loginWithGithub(){
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
                    else if error?.localizedDescription == "An account already exists with the same email address but different sign-in credentials. Sign in using a provider associated with this email address."{
                        self.activeAlert = .fourth
                    }
                    else if error?.localizedDescription == "The user account has been disabled by an administrator."{
                        self.activeAlert = .fifth
                    }
                    else if error == nil{
                        self.isGitLogin.toggle()
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
    }
    
    
    func login(){
        self.showAlert = false
        if email.isEmpty || password.isEmpty{
            self.activeAlert = .first
            self.showAlert.toggle()
            return
        }
        Auth.auth().signIn(withEmail: email, password: password){ (result, error) in
            print(error?.localizedDescription)
            if error?.localizedDescription == "The supplied auth credential is malformed or has expired."{
                self.activeAlert = .sixth
                self.showAlert.toggle()
            }
            else if error?.localizedDescription == "The user account has been disabled by an administrator."{
                self.activeAlert = .fifth
                self.showAlert.toggle()
            }
            else if error == nil{
                print("success")
                self.activeAlert = .second
                self.showAlert.toggle()
            }
        }
    }
    
    var body: some View {
        NavigationStack{
            if isGitLogin == true || isGoogleLogIn == true || isTwitterLogin == true || isLoggedIn == true{
                Maps()
            }
            else{
                VStack{
                    Image(logo) // ntu logo at top
                        .resizable()
                        .frame(width: 100 , height: 100)
                        .padding()
                    ZStack{
                        Text("Welcome to the NTU Capture The Room App \n Please login to use the app")
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
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white) // Background color matches the rectangle
                            .frame(height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.actionColour, lineWidth: 1) // Border color
                            )
                        SecureField("", text: $password, prompt: Text("Password").foregroundStyle(Color.black.opacity(0.5))) // password secure field
                            .autocapitalization(.none)
                            .textContentType(.name)
                            .foregroundColor(.black) // Text color
                            .padding(.horizontal) // Padding inside the text field
                            .frame(height: 50)
                    }
                    .padding(.horizontal) // Outer padding
                    ZStack{
                        NavigationLink(destination: ForgotPassword()){
                            Text("Forgot Password?")
                                .foregroundColor(.white)
                                .underline()
                                .padding()
                        }
                        
                    }
                    ZStack{
                        Button(action: login){ // button to register an email account
                            Text("Login")
                                .padding()
                                .foregroundStyle(Color.white)
                                .background(
                                    RoundedRectangle(
                                        cornerRadius: 20, style: .continuous)
                                    .fill(.actionColour))
                                
                            
                                .alert(isPresented: $showAlert){ //different alerts that can pop up when registering
                                    switch activeAlert {
                                    case .first:
                                        return Alert(title: Text("Email/Password is empty"), message: Text("Ensure that you enter an email and password"), dismissButton: .default(Text("Try Again"))) // is passwords do not match
                                    case .second:
                                        return Alert(title: Text("Account Created"), message: Text("Your account has been created"), dismissButton: .default(Text("Continue")){
                                            isLoggedIn.toggle()// if everyhting is ok
                                        }
                                        )
                                    case .third:
                                        return Alert(title: Text("Email already is use"), message: Text("This email is already in use, sign in with that account or create another"), dismissButton: .default(Text("Try again")))
                                        
                                    case .fourth:
                                        return Alert(title: Text("Account already exists with email"), message: Text("An account already exists using this email but it is with another provider. Please sign in with that provider"), dismissButton: .default(Text("Try Again")))
                                    case .fifth:
                                        return Alert(title: Text("Account is disabled"), message: Text("This account has been disabled by an admin, please seek user support"), dismissButton: .default(Text("Try Again")))
                                    case .sixth:
                                        return Alert(title: Text("Email or Password is incorrect"), message: Text("The entered email or password is incorrect. Please try again"), dismissButton: .default(Text("Try Again")))
                                        
                                    } // code found from https://stackoverflow.com/questions/58069516/how-can-i-have-two-alerts-on-one-view-in-swiftui
                                    //User John M
                                    
                                }
                            // Alert code is needed to display to different alerts based on one button.
                        }
                            
                    }
                    ZStack{
                        Text("Or Login with one of the following options")
                            .foregroundColor(.white)
                            .padding()
                    }
                    ZStack{
                        HStack{
                            Button{
                                loginWithGoogle()
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
                                loginWithX()
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
                                loginWithGithub()
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
                        NavigationLink(destination: Registration()){
                            Text("Haven't got an Account yet?")
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
}

#Preview {
    Login()
}

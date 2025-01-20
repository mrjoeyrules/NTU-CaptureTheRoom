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
import FirebaseFirestore

enum ActiveAlert{ // set cases for the active alert
    case first, second, third, fourth, fifth, sixth, seventh
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
    @State var isGitLogin: Bool = false
    @State var isTwitterLogin: Bool = false
    @State var activeAlert: ActiveAlert = .first // which alert flag
    @State var isEmailLogin: Bool = false
    let logo = "NTUShieldLogo" // name of logo picture
    
    func saveUserDateToFirestore(user: User, completion: @escaping (Error?) -> Void){
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "uid": user.uid,
            "email": user.email ?? "",
            "createdAt": Timestamp(date: Date())
            ]
        db.collection("users").document(user.uid).setData(userData){ error in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
            } else {
                print("Document successfully written!")
                completion(nil)
            }
            
        }
        
    }
    
    
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
                    else if error?.localizedDescription == "An account already exists with the same email address but different sign-in credentials. Sign in using a provider associated with this email address."{
                        self.activeAlert = .sixth
                    }
                    else if error?.localizedDescription == "The user account has been disabled by an administrator."{
                        self.activeAlert = .seventh
                    }
                    else if error == nil{
                        guard let user = authResult?.user else {return}
                        saveUserDateToFirestore(user: user){ error2 in
                            if let error2 = error{
                                print(error?.localizedDescription)
                            }
                        }
                        UserLocal.currentUser?.user = user
                        self.isTwitterLogin.toggle()
                        self.activeAlert = .second
                        self.showAlert.toggle()
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
                    else if error?.localizedDescription == "An account already exists with the same email address but different sign-in credentials. Sign in using a provider associated with this email address."{
                        self.activeAlert = .sixth
                    }
                    else if error?.localizedDescription == "The user account has been disabled by an administrator."{
                        self.activeAlert = .seventh
                    }
                    else if error == nil{
                        self.isGitLogin.toggle()
                        // User is signed in.
                        // IdP data available in authResult.additionalUserInfo.profile.
                        
                        guard let oauthCredential = authResult?.credential as? OAuthCredential else { return }
                        guard let user = authResult?.user else {return}
                        saveUserDateToFirestore(user: user){ error2 in
                            if let error2 = error{
                                print(error?.localizedDescription)
                            }
                        }
                        UserLocal.currentUser?.user = user
                        self.activeAlert = .second
                        self.showAlert.toggle()
                        // GitHub OAuth access token can also be retrieved by:
                        // oauthCredential.accessToken
                        // GitHub OAuth ID token can be retrieved by calling:
                        // oauthCredential.idToken
                    }
                   
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
                else if error?.localizedDescription == "An account already exists with the same email address but different sign-in credentials. Sign in using a provider associated with this email address."{
                    self.activeAlert = .sixth
                }
                else if error?.localizedDescription == "The user account has been disabled by an administrator."{
                    self.activeAlert = .seventh
                }
                else if error == nil{
                    guard let user = result?.user else {return}
                    saveUserDateToFirestore(user: user){ error2 in
                        if let error2 = error{
                            print(error?.localizedDescription)
                        }
                    }
                    UserLocal.currentUser?.user = user
                    self.activeAlert = .second
                    self.showAlert.toggle()
                    self.isGoogleLogIn.toggle()
                }
                
            }
        }
        
    }
    
    
    
    
    func register(){ // runs code when register button is pressed
        self.showAlert = false
        if email.isEmpty || password.isEmpty || confirmPassword.isEmpty{
            self.activeAlert = .first
            self.showAlert.toggle()
        }
        if password != confirmPassword{ // if passwords dont match flag as invalid
            self.activeAlert = .first
            self.showAlert.toggle()
            
        }
        else{
            
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                print(error?.localizedDescription)
                if error?.localizedDescription == "The email address is already in use by another account."{
                    self.activeAlert = .third
                    self.showAlert.toggle()
                }
                else if error?.localizedDescription == "An internal error has occurred, print and inspect the error details for more information."{
                    self.activeAlert = .fourth
                    self.showAlert.toggle()
                }
                else if error?.localizedDescription == "The email address is badly formatted."{
                    self.activeAlert = .fifth
                    self.showAlert.toggle()
                }
                else{
                    guard let user = result?.user else { return }
                    saveUserDateToFirestore(user: user){ error2 in
                        if let error2 = error{
                            print(error?.localizedDescription)
                        }
                    }
                    UserLocal.currentUser?.user = user
                    self.activeAlert = .second
                    self.showAlert.toggle()
                    
                }
            } // creates a user in firebase authentication with email and password entered.
            
            // creates a user with email and password in firebase auth
        }
    }
    
    
    var body: some View{
        
        NavigationStack{
            if isGitLogin == true || isGoogleLogIn == true || isTwitterLogin == true || isEmailLogin == true{
                FirstUserInfo()
            }
            else{
                VStack{
                    Image(logo) // ntu logo at top
                        .resizable()
                        .frame(width: 100 , height: 100)
                        .padding()
                    ZStack{
                        Text("Welcome to the NTU Capture The Room App \n Please register to use the app")
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
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white) // Background color matches the rectangle
                            .frame(height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.actionColour, lineWidth: 1) // Border color
                            )
                        SecureField("", text: $confirmPassword, prompt: Text("Confirm Password").foregroundStyle(Color.black.opacity(0.5))) // reconfirm password
                            .autocapitalization(.none)
                            .textContentType(.name)
                            .foregroundColor(.black) // Text color
                            .padding(.horizontal)// Padding inside the text field
                            .frame(height: 50)
                    }
                    .padding(.horizontal) // Outer padding
                    ZStack{
                        Button(action: register){ // button to register an email account
                            Text("Register")
                                .padding()
                                .foregroundStyle(Color.white)
                                .background(
                                    RoundedRectangle(
                                        cornerRadius: 20, style: .continuous)
                                    .fill(.actionColour))
                            
                                .alert(isPresented: $showAlert){ //different alerts that can pop up when registering
                                    switch activeAlert {
                                    case .first:
                                        return Alert(title: Text("Passwords do not match"), message: Text("Ensure that your passwords match"), dismissButton: .default(Text("Try Again"))) // is passwords do not match
                                    case .second:
                                        return Alert(title: Text("Account Created"), message: Text("Your account has been created"), dismissButton: .default(Text("Continue")){
                                            isEmailLogin.toggle() // if everyhting is ok
                                        }
                                        )
                                    case .third:
                                        return Alert(title: Text("Email already is use"), message: Text("This email is already in use, sign in with that account or create another"), dismissButton: .default(Text("Try again")))
                                    case .fourth:
                                        return Alert(title: Text("Password is not strong enough"), message: Text("Your password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, and one number"), dismissButton: .default(Text("Try Again")))
                                    case .fifth:
                                        return Alert(title: Text("Email is invalid"), message: Text("Enter a valid email address to create you account"), dismissButton: .default(Text("Try Again")))
                                    case .sixth:
                                        return Alert(title: Text("Account already exists with email"), message: Text("An account already exists using this email but it is with another provider. Please sign in with that provider"), dismissButton: .default(Text("Try Again")))
                                    case .seventh:
                                        return Alert(title: Text("Account is disabled"), message: Text("This account has been disabled by an admin, please seek user support"), dismissButton: .default(Text("Try Again")))
                                        
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
}
#Preview {
    Registration()
}

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
import FirebaseFirestore
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
    @State var firstLogin: Bool = false
    let logo = "NTUShieldLogo" // name of logo picture
    
    func showAlert(for alert: ActiveAlert2) {
        self.activeAlert = alert
        self.showAlert = false // Ensure refresh
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showAlert = true
        }
    }
    
    func getStoredUserInfo(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "No user signed in", code: 0, userInfo: nil)))
            return
        }
        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(uid)
        userDocRef.getDocument(){ documentSnapshot, error in
            if let error = error{
                print(error.localizedDescription)
                completion(.failure(error))
                return
            }
            guard let document = documentSnapshot, document.exists, let data = document.data() else {
                print("document doesnt exist or is empty")
                completion(.failure(NSError(domain: "Firestore error", code: 404, userInfo: [NSLocalizedDescriptionKey: "User doc not found"])))
                return
            }
            let username = data["username"] as! String ?? "unknown"
            let team = data["team"] as? String ?? "unknown"
            let xp = data["xp"] as! Int
            let level = data["level"] as! Int
            
            let userLocal = UserLocal(username: username)
            userLocal.team = team
            userLocal.user = Auth.auth().currentUser
            userLocal.level = level
            userLocal.xp = xp
            UserLocal.currentUser = userLocal
            completion(.success(()))
            
        }
    }
    
    
    
    func checkIfDocExists(user: User, completion: @escaping (Bool, Error?) -> Void){
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(user.uid)
        docRef.getDocument { document, error in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                completion(false, error)
                return
            }
            
            if let document = document, document.exists {
                completion(true, nil) // Document exists
            } else {
                completion(false, nil) // Document does not exist
            }
        }
    }
    
    
    func saveUserDateToFirestore(user: User, completion: @escaping (Error?) -> Void){
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "uid": user.uid,
            "email": user.email ?? "",
            "createdAt": Timestamp(date: Date()),
            "level": UserLocal.currentUser?.level ?? 1,
            "xp": UserLocal.currentUser?.xp ?? 0
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
                if let error = error as? NSError {
                    print(error.code)
                    // Check error code instead of localizedDescription
                    switch AuthErrorCode(rawValue: error.code) {
                    case .accountExistsWithDifferentCredential:
                        showAlert(for: .fourth)
                    case .userDisabled:
                        showAlert(for: .fifth)
                    default:
                        print("Error signing in: \(error.localizedDescription)")
                    }
                    return
                }
                guard let user = result?.user else {return}
                checkIfDocExists(user: user){ exists, error in
                    if let error = error{
                        print(error.localizedDescription)
                        return
                    }
                    if(!exists){
                        print("doc doesn't exists")
                        saveUserDateToFirestore(user: user) { error in
                            if let error = error{
                                print(error.localizedDescription)
                                return
                            }
                            self.firstLogin = true
                            
                            getStoredUserInfo{ result in
                                switch result{
                                case.success:
                                    print("User data stored successfully")
                                    self.isGoogleLogIn = true
                                    showAlert(for: .second)
                                case .failure:
                                    print("Failed to get user data")
                                }
                            }
                        }
                        
                    }
                    else{
                        getStoredUserInfo{ result in
                            switch result{
                            case.success:
                                print("User data stored successfully")
                                self.isGoogleLogIn = true
                                showAlert(for: .second)
                            case .failure:
                                print("Failed to get user data")
                            }
                        }
                    }
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
                    if let error = error as? NSError {
                        // Check error code instead of localizedDescription
                        switch AuthErrorCode(rawValue: error.code) {
                        case .accountExistsWithDifferentCredential:
                            showAlert(for: .fourth)
                        case .userDisabled:
                            showAlert(for: .fifth)
                        default:
                            print("Error signing in with twitter: \(error.localizedDescription)")
                        }
                        return
                    }
                    guard let user = authResult?.user else {return}
                    checkIfDocExists(user: user){ exists, error in
                        if let error = error{
                            print(error.localizedDescription)
                            return
                        }
                        if(!exists){
                            print("doc doesn't exists")
                            saveUserDateToFirestore(user: user) { error in
                                if let error = error{
                                    print(error.localizedDescription)
                                    return
                                }
                                
                                self.firstLogin = true
                                getStoredUserInfo{ result in
                                    switch result{
                                    case.success:
                                        print("User data stored successfully")
                                        self.isTwitterLogin = true
                                        showAlert(for: .second)
                                    case .failure:
                                        print("Failed to get user data")
                                    }
                                }
                            }
                            
                        }
                        else{
                            getStoredUserInfo{ result in
                                switch result{
                                case.success:
                                    print("User data stored successfully")
                                    self.isTwitterLogin = true
                                    showAlert(for: .second)
                                case .failure:
                                    print("Failed to get user data")
                                }
                            }
                        }
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
                    if let error = error as? NSError {
                        print(error.code)
                        // Check error code instead of localizedDescription
                        switch AuthErrorCode(rawValue: error.code) {
                        case .accountExistsWithDifferentCredential:
                            showAlert(for: .fourth)
                        case .userDisabled:
                            showAlert(for: .fifth)
                        default:
                            print("Error signing in: \(error.localizedDescription)")
                        }
                        return
                    }
                    
                    guard let oauthCredential = authResult?.credential as? OAuthCredential else { return }
                    guard let user = authResult?.user else { return }
                    checkIfDocExists(user: user){ exists, error in
                        if let error = error{
                            print(error.localizedDescription)
                            return
                        }
                        if(exists == false){
                            print("doc doesn't exists")
                            saveUserDateToFirestore(user: user) { error in
                                if let error = error{
                                    print(error.localizedDescription)
                                    return
                                }
                                self.firstLogin = true
                                getStoredUserInfo{ result in
                                    switch result{
                                    case.success:
                                        print("User data stored successfully")
                                        self.isGitLogin = true
                                        showAlert(for: .second)
                                    case .failure:
                                        print("Failed to get user data")
                                    }
                                }
                            }
                            
                        }
                        else{
                            getStoredUserInfo{ result in
                                switch result{
                                case.success:
                                    print("User data stored successfully")
                                    self.isGoogleLogIn = true
                                    showAlert(for: .second)
                                case .failure:
                                    print("Failed to get user data")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
        
    func loginEmail(){
        self.showAlert = false
        if email.isEmpty || password.isEmpty{
            self.activeAlert = .first
            self.showAlert.toggle()
            return
        }
        Auth.auth().signIn(withEmail: email, password: password){ (result, error) in
            print(error?.localizedDescription)
            if let error = error as? NSError {
                print(error.code)
                // Check error code instead of localizedDescription
                switch AuthErrorCode(rawValue: error.code) {
                case .accountExistsWithDifferentCredential:
                    showAlert(for: .fourth)
                case .userDisabled:
                    showAlert(for: .fifth)
                case .invalidRecipientEmail:
                    showAlert(for: .sixth)
                case .wrongPassword:
                    showAlert(for: .sixth)
                case .invalidEmail:
                    showAlert(for: .sixth)
                case .invalidCredential:
                    showAlert(for: .sixth)
                default:
                    print("Error signing in: \(error.localizedDescription)")
                }
                return
            }
            print("success")
            guard let user = result?.user else { return } // get user to get uid for later use
            UserLocal.currentUser?.user = user
            getStoredUserInfo{ result in
                switch result{
                case.success:
                    print("User data stored successfully")
                    self.isGoogleLogIn = true
                    showAlert(for: .second)
                case .failure:
                    print("Failed to get user data")
                }
            }
        }
    }
    var body: some View {
        NavigationStack{
            if firstLogin == true{
                FirstUserInfo()
            }else if isGitLogin == true || isGoogleLogIn == true || isTwitterLogin == true || isLoggedIn == true{
                Tabs(selectedTab: .maps)
            }else{
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
                            Button(action: loginEmail){ // button to register an email account
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

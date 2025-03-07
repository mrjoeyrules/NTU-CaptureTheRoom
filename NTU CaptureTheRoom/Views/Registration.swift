

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
    @State var isFirstLogin = false
    @State var password: String = "" // inputed password
    @State var confirmPassword: String = "" // password re-entered
    @State var showAlert: Bool = false // show alert flag
    @State var isGoogleLogIn: Bool = false
    @State var isGitLogin: Bool = false
    @State var isTwitterLogin: Bool = false
    @State var activeAlert: ActiveAlert = .first // which alert flag
    @State var isEmailLogin: Bool = false
    let logo = "NTUShieldLogo" // name of logo picture
    
    func showAlert(for alert: ActiveAlert) {
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
            let xp = data["xp"] as! CGFloat
            let totalsteps = data["totalsteps"] as! Int
            let roomscapped = data["roomscapped"] as! Int
            let level = data["level"] as! Int
            let setUpStatus = data["setupstatus"] as? String ?? "notSetUp"
            
            let userLocal = UserLocal(username: username)
            userLocal.team = team
            userLocal.setUpStatus = setUpStatus
            userLocal.user = Auth.auth().currentUser
            userLocal.level = level
            userLocal.roomsCapped = roomscapped
            userLocal.totalSteps = totalsteps
            userLocal.xp = xp
            UserLocal.currentUser = userLocal
            completion(.success(()))
            
        }
    }
    
    
    
    func checkIfUserDocExists(uid: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let db = Firestore.firestore()
        let userDocReference = db.collection("users").document(uid)
        
        userDocReference.getDocument { documentSnapshot, error in
            if let error = error {
                print("Error checking document: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let document = documentSnapshot, document.exists {
                print("Document for this user \(uid) exists")
                completion(.success(true))
            } else {
                print("Document not found for user \(uid)")
                completion(.success(false))
            }
        }
    }
    
    
    func saveUserDateToFirestore(user: User,loginType: String , completion: @escaping (Error?) -> Void){
        let db = Firestore.firestore()
        
        
        let userData: [String: Any] = [
            "uid": user.uid,
            "email": user.email ?? "",
            "account type": loginType,
            "createdAt": Timestamp(date: Date()),
            "level": UserLocal.currentUser?.level ?? 1,
            "xp": UserLocal.currentUser?.xp ?? 0,
            "username": "unselected",
            "team": "unselected",
            "setupstatus": "in-progress",
            "roomscapped": UserLocal.currentUser?.roomsCapped ?? 0,
            "totalsteps": UserLocal.currentUser?.totalSteps ?? 0
            ]
        db.collection("users").document(user.uid).setData(userData){ error in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
            } else {
                print("Document successfully written!")
                if user.displayName != nil{
                    UserLocal.currentUser = UserLocal(username: user.displayName!)
                }
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
                    if let error = error as? NSError {
                        // Check error code instead of localizedDescription
                        switch AuthErrorCode(rawValue: error.code) {
                        case .accountExistsWithDifferentCredential:
                            showAlert(for: .sixth)
                        case .userDisabled:
                            showAlert(for: .seventh)
                        default:
                            print("Error signing in: \(error.localizedDescription)")
                        }
                        return
                    }
                    guard let user = authResult?.user else {return}
                    
                    checkIfUserDocExists(uid: user.uid){ result in
                        switch result{
                        case .success(let exists):
                            if exists{
                                isFirstLogin = false
                                getStoredUserInfo{ result in
                                    switch result{
                                    case.success:
                                        print("User data stored successfully")
                                        isTwitterLogin = true
                                        showAlert(for: .second)
                                    case .failure:
                                        print("Failed to get user data")
                                    }
                                }
                            }else{
                                isFirstLogin = true
                                saveUserDateToFirestore(user: user, loginType: "Twitter"){ error2 in
                                    if let error2 = error{
                                        print(error?.localizedDescription)
                                    }
                                }
                                getStoredUserInfo{ result in
                                    switch result{
                                    case.success:
                                        print("User data stored successfully")
                                        isTwitterLogin = true
                                        showAlert(for: .second)
                                    case .failure:
                                        print("Failed to get user data")
                                    }
                                }
                            }
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
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
                    if let error = error as? NSError {
                        print(error.code)
                        // Check error code instead of localizedDescription
                        switch AuthErrorCode(rawValue: error.code) {
                        case .accountExistsWithDifferentCredential:
                            showAlert(for: .sixth)
                        case .userDisabled:
                            showAlert(for: .seventh)
                        default:
                            print("Error signing in with GitHub: \(error.localizedDescription)")
                        }
                        return
                    }
                    
                    guard let oauthCredential = authResult?.credential as? OAuthCredential else { return }
                    guard let user = authResult?.user else {return}
                    let accessToken = oauthCredential.accessToken
                    checkIfUserDocExists(uid: user.uid){ result in
                        switch result{
                        case .success(let exists):
                            if exists{
                                isFirstLogin = false
                                getStoredUserInfo{ result in
                                    switch result{
                                    case.success:
                                        print("User data stored successfully")
                                        isGitLogin = true
                                        showAlert(for: .second)
                                    case .failure:
                                        print("Failed to get user data")
                                    }
                                }
                            }else{
                                isFirstLogin = true
                                saveUserDateToFirestore(user: user, loginType: "GitHub"){ error2 in
                                    if let error2 = error{
                                        print(error?.localizedDescription)
                                    }
                                    isGitLogin = true
                                    UserLocal.currentUser?.user = user
                                    showAlert(for: .second)
                                }
                                getStoredUserInfo{ result in
                                    switch result{
                                    case.success:
                                        print("User data stored successfully")
                                        isGitLogin = true
                                        showAlert(for: .second)
                                    case .failure:
                                        print("Failed to get user data")
                                    }
                                }
                            }
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
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
                if let error = error as? NSError {
                    print(error.code)
                    // Check error code instead of localizedDescription
                    switch AuthErrorCode(rawValue: error.code) {
                    case .accountExistsWithDifferentCredential:
                        showAlert(for: .sixth)
                    case .userDisabled:
                        showAlert(for: .seventh)
                    default:
                        print("Error signing in: \(error.localizedDescription)")
                    }
                    return
                }
                guard let user = result?.user else {return}
               
                checkIfUserDocExists(uid: user.uid){ result in
                    switch result{
                    case .success(let exists):
                        if exists{
                            getStoredUserInfo{ result in
                                switch result{
                                case.success:
                                    print("User data stored successfully")
                                    isGoogleLogIn = true
                                    showAlert(for: .second)
                                case .failure:
                                    print("Failed to get user data")
                                }
                            }
                            isFirstLogin = false
                        }else{
                            isFirstLogin = true
                            saveUserDateToFirestore(user: user, loginType: "Google"){ error2 in
                                if let error2 = error{
                                    print(error?.localizedDescription)
                                }
                            }
                            getStoredUserInfo{ result in
                                switch result{
                                case.success:
                                    print("User data stored successfully")
                                    isGoogleLogIn = true
                                    
                                    showAlert(for: .second)
                                case .failure:
                                    print("Failed to get user data")
                                }
                            }
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
        
    }
    
    
    
    
    func register(){ // runs code when register button is pressed
        self.showAlert = false
        if email.isEmpty || password.isEmpty || confirmPassword.isEmpty{
            showAlert(for: .first)
        }
        if password != confirmPassword{ // if passwords dont match flag as invalid
            showAlert(for: .first)
            
        }
        else{
            
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                print(error?.localizedDescription)
                if let error = error as? NSError {
                    // Check error code instead of localizedDescription
                    switch AuthErrorCode(rawValue: error.code) {
                    case .emailAlreadyInUse:
                        showAlert(for: .sixth)
                    case .userDisabled:
                        showAlert(for: .seventh)
                    case .invalidRecipientEmail:
                        showAlert(for: .fifth)
                    default:
                        print("Error signing in: \(error.localizedDescription)")
                    }
                    return
                }
                else{
                    guard let user = result?.user else { return }
                    isFirstLogin = true
                    saveUserDateToFirestore(user: user, loginType: "Email"){ error2 in
                        if let error2 = error{
                            print(error?.localizedDescription)
                        }
                    }
                    getStoredUserInfo{ result in
                        switch result{
                        case.success:
                            print("User data stored successfully")
                            isEmailLogin = true
                            showAlert(for: .second)
                        case .failure:
                            print("Failed to get user data")
                        }
                    }
                }
            }
        }
    }
    
    
    var body: some View{
        
        NavigationStack{
            if (isGoogleLogIn == true || isEmailLogin == true || isGitLogin == true || isTwitterLogin == true) && (isFirstLogin == true || UserLocal.currentUser?.setUpStatus == "in-progress" || UserLocal.currentUser?.setUpStatus == "notSetUp"){
                FirstUserInfo()
            }
            else if(isGoogleLogIn == true || isGitLogin == true || isTwitterLogin == true || isEmailLogin == true) && isFirstLogin == false && UserLocal.currentUser?.setUpStatus == "complete"{
                Tabs(selectedTab: .maps)
            }
            else{
                VStack{
                    Image(logo) // App logo
                        .resizable()
                        .frame(width: 100 , height: 100)
                        .padding()
                    ZStack{
                        Text("Welcome to the NTU Capture the room App \nPlease register to use the app")
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
                .navigationBarBackButtonHidden(true)
            }
        }
    }
}

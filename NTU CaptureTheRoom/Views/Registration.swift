//
//  ForgotPassword.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 29/11/2024.
//




import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Foundation
import GoogleSignIn
import SwiftUI

enum ActiveAlert { // set cases for the active alert
    case first, second, third, fourth, fifth, sixth, seventh, eighth
}

struct Registration: View {
    let twitterProvider = OAuthProvider(providerID: "twitter.com") // providers for third party auth

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

    func showAlert(for alert: ActiveAlert) { // func to show an alert. sets the active alert to passed value from the enum
        activeAlert = alert
        showAlert = false // Ensure refresh
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showAlert = true // shows alert in the main thread.
        }
    }

    func getStoredUserInfo(completion: @escaping (Result<Void, Error>) -> Void) { // get all user info from FS and store in UserLocal object current user
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "No user signed in", code: 0, userInfo: nil)))
            return
        }
        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(uid) // get the actual document
        userDocRef.getDocument { documentSnapshot, error in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(error))
                return
            }
            guard let document = documentSnapshot, document.exists, let data = document.data() else { // check that the document exists and that it is full of data.
                print("document doesnt exist or is empty")
                completion(.failure(NSError(domain: "Firestore error", code: 404, userInfo: [NSLocalizedDescriptionKey: "User doc not found"])))
                return
            }
            let username = data["username"] as! String
            let team = data["team"] as? String ?? "unknown"
            let xp = data["xp"] as! CGFloat
            let totalsteps = data["totalsteps"] as! Int
            let roomscapped = data["roomscapped"] as! Int // get all info from FS and store in variables
            let level = data["level"] as! Int
            let showTutorial = data["showtutorial"] as! Bool
            let totalXp = data["totalxp"] as! CGFloat
            var formattedDate: String = "Unknown Date"
            if let dateJoined = data["createdAt"] as? Timestamp {
                formattedDate = formatDate(dateJoined.dateValue()) // format the date
            }
            let setUpStatus = data["setupstatus"] as? String ?? "notSetUp"

            let userLocal = UserLocal(username: username)
            userLocal.team = team
            userLocal.setUpStatus = setUpStatus
            userLocal.user = Auth.auth().currentUser // set all info in an object of UserLocal
            userLocal.level = level
            userLocal.showTutorial = showTutorial
            userLocal.roomsCapped = roomscapped
            userLocal.dateJoined = formattedDate
            userLocal.totalSteps = totalsteps
            userLocal.totalXp = totalXp
            userLocal.xp = xp
            UserLocal.currentUser = userLocal
            completion(.success(()))
        }
    }

    func formatDate(_ date: Date) -> String { // formats date
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none // removes time stamp from date
        return formatter.string(from: date)
    }

    func checkIfUserDocExists(uid: String, completion: @escaping (Result<Bool, Error>) -> Void) { // checking if the users already has a document in FS.
        let db = Firestore.firestore()
        let userDocReference = db.collection("users").document(uid) // Check users collection for a doc named the users uid

        userDocReference.getDocument { documentSnapshot, error in
            if let error = error {
                print("Error checking document: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            if let document = documentSnapshot, document.exists { // if document.exists is true this the document exists
                print("Document for this user \(uid) exists")
                completion(.success(true))
            } else {
                print("Document not found for user \(uid)") // else it doesnt send false flag
                completion(.success(false))
            }
        }
    }

    func saveUserDateToFirestore(user: User, loginType: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        //let fcmToken = UserDefaults.standard.string(forKey: "fcmToken") ?? ""
        let userData: [String: Any] = [ // a dictionary for user data to be saved String key with any data type as whats being entered
            "uid": user.uid,
            "email": user.email ?? "",
            "account type": loginType,
            "createdAt": Timestamp(date: Date()),
            "level": UserLocal.currentUser?.level ?? 1, // when creating an account set all info in FS
            "xp": UserLocal.currentUser?.xp ?? 0,
            "showtutorial": UserLocal.currentUser?.showTutorial ?? true,
            "username": "unselected",
            "team": "unselected",
            "setupstatus": "in-progress",
            "roomscapped": UserLocal.currentUser?.roomsCapped ?? 0,
            "totalsteps": UserLocal.currentUser?.totalSteps ?? 0,
            "totalxp": UserLocal.currentUser?.totalXp ?? 0,
        ]
        /*
        if !fcmToken.isEmpty{
            userData["fcmToken"] = fcmToken
        }
         */
        db.collection("users").document(user.uid).setData(userData, merge: true){ error in
            if let error = error {
                print("Error writing document: \(error)")
                completion(error)
            } else {
                print("Document successfully written!") // write data return nil
                completion(nil)
            }
            
        }
    }

    func RegisterX() {
        twitterProvider.getCredentialWith(nil) { twitterCredential, error in // provider from top of file get creds
            if error != nil {
                print(error?.localizedDescription ?? "error")
            }
            if twitterCredential != nil { // if creds are not nil
                print("Twitter creds: \(twitterCredential)")
                Auth.auth().signIn(with: twitterCredential!) { authResult, error in // FB auth using twitter credentials
                    if let error = error as? NSError {
                        // Check error code instead of localizedDescription
                        switch AuthErrorCode(rawValue: error.code) { // different error codes possible
                        case .accountExistsWithDifferentCredential: // user exists with other login type
                            showAlert(for: .sixth)
                        case .userDisabled: // if user is disabled
                            showAlert(for: .seventh)
                        default:
                            print("Error signing in: \(error.localizedDescription)") // generic error incase not picked up in switch case
                        }
                        return
                    }
                    guard let user = authResult?.user else { return } // set user to be the authResult from FB

                    checkIfUserDocExists(uid: user.uid) { result in // check if the user already has an account doc in FS
                        switch result {
                        case let .success(exists): // if return is true for checkuser get the stored user info from FS
                            if exists {
                                isFirstLogin = false
                                getStoredUserInfo { result in
                                    switch result {
                                    case .success:
                                        print("User data stored successfully")
                                        isTwitterLogin = true // set twitter flag true
                                        showAlert(for: .second) // show login alert
                                    case .failure:
                                        print("Failed to get user data")
                                    }
                                }
                            } else {
                                isFirstLogin = true // if doc doesnt exist first login is true
                                saveUserDateToFirestore(user: user, loginType: "Twitter") { _ in // save base user data to FS set logintype flag for FS
                                    if let error2 = error {
                                        print(error2.localizedDescription)
                                    }
                                }
                                getStoredUserInfo { result in // Then get the user info from FS
                                    switch result {
                                    case .success:
                                        print("User data stored successfully")
                                        isTwitterLogin = true // set twitter login flag true
                                        showAlert(for: .second) // show login alert
                                    case .failure:
                                        print("Failed to get user data")
                                    }
                                }
                            }
                        case let .failure(error):
                            print(error.localizedDescription) // incase any overall error print, shouldnt occur
                        }
                    }
                }
            }
        }
    }

    func RegisterGithub() {
        print("github")
        let provider = OAuthProvider(providerID: "github.com")

        provider.getCredentialWith(nil) { gitCredential, error in
            if let error = error {
                print("Error getting GitHub credential: \(error.localizedDescription)")
                return
            }

            if let gitCredential = gitCredential {
                Auth.auth().signIn(with: gitCredential) { authResult, error in
                    if let error = error as? NSError {
                        print("Error signing in with GitHub: \(error.localizedDescription)")
                        // Handle specific error codes
                        switch AuthErrorCode(rawValue: error.code) {
                        case .accountExistsWithDifferentCredential:
                            showAlert(for: .sixth)
                        case .userDisabled:
                            showAlert(for: .seventh)
                        default:
                            print("Unknown error: \(error.localizedDescription)")
                        }
                        return
                    }

                    guard let user = authResult?.user else { return }
                    checkIfUserDocExists(uid: user.uid) { result in
                        switch result {
                        case .success(let exists):
                            if exists {
                                isFirstLogin = false
                                getStoredUserInfo { result in
                                    switch result {
                                    case .success:
                                        print("User data stored successfully")
                                        isGitLogin = true
                                        showAlert(for: .second)
                                    case .failure:
                                        print("Failed to get user data")
                                    }
                                }
                            } else {
                                isFirstLogin = true
                                saveUserDateToFirestore(user: user, loginType: "GitHub") { error in
                                    if let error = error {
                                        print("Error saving user data: \(error.localizedDescription)")
                                    }
                                    isGitLogin = true
                                }
                                getStoredUserInfo { result in
                                    switch result {
                                    case .success:
                                        print("User data stored successfully")
                                        isGitLogin = true
                                        showAlert(for: .second)
                                    case .failure:
                                        print("Failed to get user data")
                                    }
                                }
                            }
                        case .failure(let error):
                            print("Error checking user document: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }

    func RegisterGoogle() {
        guard let clientId = FirebaseApp.app()?.options.clientID else { return } // google login code from firebase docs for iOS

        _ = GIDConfiguration(clientID: clientId) // config for Google signin

        GIDSignIn.sharedInstance.signIn(withPresenting: ApplicationUtility.rootViewController) { // Issue with getting google signin page to pop up had to make a application utility folder for google login
            signResult, err in
            if let error = err {
                print(error.localizedDescription)
                return
            }
            guard let user = signResult?.user,
                  let idToken = user.idToken // get id token from user
            else {
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: user.accessToken.tokenString) // get creds using id token and user access token

            Auth.auth().signIn(with: credential) { result, error in // sign in to FB using credential code from firebase docs
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
                guard let user = result?.user else { return }

                checkIfUserDocExists(uid: user.uid) { result in // check if user doc exists same as all other 3rd party logins with different flags
                    switch result {
                    case let .success(exists):
                        if exists {
                            getStoredUserInfo { result in
                                switch result {
                                case .success:
                                    print("User data stored successfully")
                                    isGoogleLogIn = true
                                    showAlert(for: .second)
                                case .failure:
                                    print("Failed to get user data")
                                }
                            }
                            isFirstLogin = false
                        } else {
                            isFirstLogin = true
                            saveUserDateToFirestore(user: user, loginType: "Google") { _ in
                                if let error2 = error {
                                    print(error2.localizedDescription)
                                }
                            }
                            getStoredUserInfo { result in
                                switch result {
                                case .success:
                                    print("User data stored successfully")
                                    isGoogleLogIn = true

                                    showAlert(for: .second)
                                case .failure:
                                    print("Failed to get user data")
                                }
                            }
                        }
                    case let .failure(error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }

    func register() { // runs code when register button is pressed
        showAlert = false
        if email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            showAlert(for: .first)
        }
        if password != confirmPassword { // if passwords dont match flag as invalid
            showAlert(for: .first)
        } else {
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                print(error?.localizedDescription ?? "error")
                if let error = error as? NSError {
                    print("full error \(error)")
                    // Check error code instead of localizedDescription
                    // different types of error codes for a manual account
                    switch AuthErrorCode(rawValue: error.code) {
                    case .emailAlreadyInUse:
                        showAlert(for: .sixth)
                    case .userDisabled:
                        showAlert(for: .seventh)
                    case .invalidRecipientEmail:
                        showAlert(for: .fifth)
                    case .weakPassword:
                        showAlert(for: .eighth)
                    default:
                        if error.domain == "FIRAuthErrorDomain", let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NSError, // if the error contains FIRAuthErrorDomain
                           let errorDetails = underlyingError.userInfo["FIRAuthErrorUserInfoDeserializedResponseKey"] as? [String: Any], // and underlying error = FIRAuthErrorUserInfoDeserializedResponseKey
                           let message = errorDetails["message"] as? String, // and the message contains PasswordDoesNotMeetRequirements
                           message.contains("PASSWORD_DOES_NOT_MEET_REQUIREMENTS") {
                            showAlert(for: .eighth) // show eight alert type
                        } // for some reason password requirment NS code flag doesnt work so had to manually check the error

                        print("Error signing in: \(error.localizedDescription)") // if not a password requirement error print error info
                    }
                    return
                } else {
                    guard let user = result?.user else { return } // get the user from the login result user
                    isFirstLogin = true // set first login to be true because its always going to be true
                    saveUserDateToFirestore(user: user, loginType: "Email") { _ in
                        if let error2 = error {
                            print(error2.localizedDescription)
                        }
                    }
                    getStoredUserInfo { result in // get the users stored info
                        switch result {
                        case .success:
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

    var body: some View {
        NavigationStack {
            if (isGoogleLogIn == true || isEmailLogin == true || isGitLogin == true || isTwitterLogin == true) && (isFirstLogin == true || UserLocal.currentUser?.setUpStatus == "in-progress" || UserLocal.currentUser?.setUpStatus == "notSetUp") { // all neccessary flags to access firstuserinfo page
                FirstUserInfo()
            } else if (isGoogleLogIn == true || isGitLogin == true || isTwitterLogin == true || isEmailLogin == true) && isFirstLogin == false && UserLocal.currentUser?.setUpStatus == "complete" { // all neccessary flag to log straight in
                Tabs(selectedTab: .maps)
            } else {
                VStack {
                    Image(logo) // NTU LOGO
                        .resizable()
                        .frame(width: 150, height: 150)
                        .padding()
                    ZStack {
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
                        TextField("", text: $email, prompt: Text("Email").foregroundStyle(Color.black.opacity(0.5))) // email text field
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
                            .padding(.horizontal) // Padding inside the text field
                            .frame(height: 50)
                    }
                    .padding(.horizontal) // Outer padding
                    ZStack {
                        Button(action: register) { // button to register an email account
                            Text("Register")
                                .padding()
                                .foregroundStyle(Color.white)
                                .background(
                                    RoundedRectangle(
                                        cornerRadius: 20, style: .continuous)
                                        .fill(.actionColour))

                                .alert(isPresented: $showAlert) { // different alerts that can pop up when registering
                                    switch activeAlert {
                                    case .first:
                                        return Alert(title: Text("Passwords do not match"), message: Text("Ensure that your passwords match"), dismissButton: .default(Text("Try Again"))) // is passwords do not match
                                    case .second:
                                        return Alert(title: Text("Account Created"), message: Text("Your account has been created"), dismissButton: .default(Text("Continue")) {
                                            isEmailLogin.toggle() // if everyhting is ok
                                        }
                                        )
                                    case .third: // all different alert popups
                                        return Alert(title: Text("Email already is use"), message: Text("This email is already in use, sign in with that account or create another"), dismissButton: .default(Text("Try again")))
                                    case .fourth:
                                        return Alert(title: Text("Password is not strong enough"), message: Text("Your password must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, and one number"), dismissButton: .default(Text("Try Again")))
                                    case .fifth:
                                        return Alert(title: Text("Email is invalid"), message: Text("Enter a valid email address to create you account"), dismissButton: .default(Text("Try Again")))
                                    case .sixth:
                                        return Alert(title: Text("Account already exists with email"), message: Text("An account already exists using this email but it is with another provider. Please sign in with that provider"), dismissButton: .default(Text("Try Again")))
                                    case .seventh:
                                        return Alert(title: Text("Account is disabled"), message: Text("This account has been disabled by an admin, please seek user support"), dismissButton: .default(Text("Try Again")))
                                    case .eighth:
                                        return Alert(title: Text("Password too weak"), message: Text("Passwords must be at least 8 characters long and contain at least one uppercase letter, one lowercase letter, and one number"), dismissButton: .default(Text("Try Again")))
                                    } // code found from https://stackoverflow.com/questions/58069516/how-can-i-have-two-alerts-on-one-view-in-swiftui
                                    // User John M
                                }
                            // Alert code is needed to display to different alerts based on one button.
                        }
                    }
                    ZStack {
                        Text("Or Register with one of the following options")
                            .foregroundColor(.white)
                            .padding()
                    }
                    ZStack { // 3rd party login buttons
                        HStack {
                            Button {
                                RegisterGoogle()
                            } label: {
                                VStack {
                                    Image("GoogleLogo")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .padding()
                                        .background(Color.googleColour)
                                }
                            }
                            .padding()

                            /* // had to remove other login methods becuase all of a sudden they refuse to redirect back and i cannot figure it out at all

                            Button {
                                RegisterX()
                            } label: {
                                VStack {
                                    Image("XLogo")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .padding()
                                        .background(Color.black)
                                }
                            }
                            .padding()
                            
                            Button {
                                RegisterGithub()
                            } label: {
                                VStack {
                                    Image("GithubLogo")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .padding()
                                        .background(Color.githubColour)
                                }
                            }
                            .padding()
                             */
                             
                        }
                    }
                    ZStack {
                        NavigationLink(destination: Login()) { // go to login page
                            Text("Already have an account?")
                                .foregroundColor(.white)
                                .underline()
                                .padding()
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    Color.background
                        .ignoresSafeArea() // set background
                }
                .navigationBarBackButtonHidden(true) // hide back button on this page
            }
        }
    }
}

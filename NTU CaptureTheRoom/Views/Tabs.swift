//
//  Tabs.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 26/01/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct Tabs: View {
    @State var selectedTab: Tab = .maps
    enum Tab: Hashable {
        case profile
        case maps
        case nearby
    }
    
    
    
    func getStoredUserInfo(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "No user signed in", code: 0, userInfo: nil)))
            return
        }
        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(uid)
        userDocRef.getDocument { documentSnapshot, error in
            if let error = error {
                print(error.localizedDescription)
                completion(.failure(error))
                return
            }
            guard let document = documentSnapshot, document.exists, let data = document.data() else {
                print("document doesnt exist or is empty")
                completion(.failure(NSError(domain: "Firestore error", code: 404, userInfo: [NSLocalizedDescriptionKey: "User doc not found"])))
                return
            }
            let username = data["username"] as! String
            let team = data["team"] as? String ?? "unknown"
            let xp = data["xp"] as! CGFloat
            let totalsteps = data["totalsteps"] as! Int
            let roomscapped = data["roomscapped"] as! Int
            let level = data["level"] as! Int
            let totalXp = data["totalxp"] as! CGFloat
            var formattedDate: String = "Unknown Date"
            if let dateJoined = data["createdAt"] as? Timestamp {
                formattedDate = formatDate(dateJoined.dateValue())
            }
            let setUpStatus = data["setupstatus"] as? String ?? "notSetUp"

            let userLocal = UserLocal(username: username)
            userLocal.team = team
            userLocal.setUpStatus = setUpStatus
            userLocal.user = Auth.auth().currentUser
            userLocal.level = level
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

    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            TabView(selection: $selectedTab) {
                NavigationStack {
                    Profile()
                }
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(Tab.profile)

                NavigationStack {
                    Maps()
                }
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(Tab.maps)

                NavigationStack {
                    Nearby()
                }
                .tabItem {
                    Label("Nearby", systemImage: "mappin")
                }
                .tag(Tab.nearby)
            }
        }
        .navigationBarBackButtonHidden(true)
        .tint(Color.actionColour)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color.background
                .ignoresSafeArea()
        }
        .onAppear{
            getStoredUserInfo { result in
                switch result {
                case .success:
                    print("User data stored successfully")
                case .failure:
                    print("Failed to get user data")
                }
            }
        }
    }
}

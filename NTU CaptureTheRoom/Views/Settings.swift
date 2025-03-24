//
//  Settings.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 03/02/2025.
//

import FirebaseAuth
import SwiftUI

struct Settings: View {
    @ObservedObject var settings = MapSettings()
    @EnvironmentObject var tutorial: TutorialManager
    
    
    func signOut() {
        do{
            try Auth.auth().signOut() // signs the user out within the firebase auth
            
            UserLocal.currentUser = nil // clear current user
            
            UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!) //clears all userdefaults values in the app under my bundle indentifier 
            UserDefaults.standard.synchronize()
            
            DispatchQueue.main.async{
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = scene.windows.first{
                    window.rootViewController = UIHostingController(rootView: Registration()) // send user back to registration
                    window.makeKeyAndVisible()
                }
            }
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                // Title
                Text("Settings")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 20)

                // map settings
                VStack(alignment: .leading, spacing: 10) {
                    Text("MAP THEME")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .padding(.leading, 20)

                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.black.opacity(0.2)) // Background of picker
                            .frame(height: 50)

                        HStack {
                            Text("Select Theme")
                                .foregroundColor(.white) // Ensure text shows
                                .padding(.leading, 15)

                            Spacer()
                            
                            Picker("", selection: $settings.selectedTheme) {
                                ForEach(MapTheme.allCases, id: \.self) { theme in
                                    Text(theme.rawValue.capitalized)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .accentColor(Color.sstColour) //Changes the selected option color
                        }
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 10)

                Spacer()
                Button(action: { // tutorial reset
                    UserDefaults.standard.set(false, forKey: "hasSeenTutorial") // set default flag to false
                    tutorial.restartTutorial() // run restart func
                }) {
                    Text("Replay Tutorial") // formatting for button
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.actionColour) //  button formatting
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 50)
                }
                
                
                
                Spacer()
                
                Button(action: { // sign out button
                    signOut()
                }) {
                    Text("Sign Out")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.actionColour) //  button formatting
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 50)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background.ignoresSafeArea())
        }
    }
}

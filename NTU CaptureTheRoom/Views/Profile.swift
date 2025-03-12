//
//  Profile.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 26/01/2025.
//

import FirebaseAuth
import SwiftUI
import Combine
import FirebaseFirestore

struct Profile: View {

    
    
    
    var body: some View {
        ZStack{
            Color.background.ignoresSafeArea()
            ScrollView{ // make whole page scrollable
                VStack(spacing: 10){
                    
                    
                    ZStack {
                        // Centered Profile Text
                        Text("Profile")
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .center) // Forces full-width and centers text
                        
                        // Settings Button on the Right
                        HStack {
                            Spacer()
                            NavigationLink(destination: Settings()) {
                                // similar to maps leadboard and scan button
                                Image(systemName: "gearshape.fill") // Settings Icon
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Color.actionColour)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing) // Pushes button to the right
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 5)
                    
                    // Profile info
                    VStack(spacing: 2) {
                        
                        
                        HStack{
                            Text("Username: ") // username text
                                .font(.title2)
                            
                            Text(UserLocal.currentUser?.username ?? "Username not found")
                                .font(.title2)
                                .fontWeight(.medium)
                        }
                        HStack{
                            Text("Team: ") // team text
                                .font(.title2)
                            Text(UserLocal.currentUser?.team ?? "Team Not Found")
                                .font(.title2)
                                .fontWeight(.medium)
                        }
                        
                        
                    }
                    .padding(.top, 10)
                    
                    // user level
                    Text("Level: \(UserLocal.currentUser?.level ?? 0)")
                        .font(.headline)
                        .padding(.top, 5)
                    
                    
                    // XP Bar
                    XpBar()
                        .padding(.top, 5)
                    
                    
                    VStack{
                        Text("User Statistics")
                            .font(.headline)
                            .bold()
                            .padding(.bottom, 5)
                        UserStats()
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15).fill(Color.background.opacity(0.2))) // box around user stats section
                    .frame(maxWidth: .infinity, alignment: .top)
                    
                    Spacer()
                    VStack{
                        Achievements() // acheivements view on screen
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15).fill(Color.background.opacity(0.2)))
                    .frame(maxWidth: .infinity, alignment: .top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    Color.background // background colour
                        .ignoresSafeArea()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline) // centers nav bar at top
    }
}

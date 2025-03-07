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
        VStack {
            HStack {
                Spacer()
                NavigationLink(destination: Settings()) {
                    Image(systemName: "gearshape.fill") // Settings Icon
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.actionColour)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .padding(.trailing, 20)
                .padding(.top, 10)
            }

            // Profile Title and Username
            VStack(spacing: 2) {
                Text("Profile")
                    .font(.title)
                    .fontWeight(.bold)

                Text(UserLocal.currentUser?.username ?? "Username not found")
                    .font(.title)
                    .fontWeight(.medium)
            }

            VStack {
                Text("Level: \(UserLocal.currentUser?.level ?? 0)")
            }
            // XP Bar
            VStack {
                XpBar()
            }
            
            

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color.background
                .ignoresSafeArea()
        }
    }
}

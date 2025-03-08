//
//  XPBar.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 07/03/2025.
//

import SwiftUI

struct XpBar: View {
    @State private var currentXp = UserLocal.currentUser?.xp ?? 0
    @State private var maxXp: CGFloat = 200
    @ObservedObject private var colourSelector = ColourSelector()

    var body: some View {
        VStack(spacing: 20) {
            ZStack(alignment: .leading) {
                
                    
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 300, height: 20) // set frame for xp bar
                    .foregroundColor(Color.gray.opacity(0.3))
                    .shadow(color: colourSelector.getShadowColour(team: UserLocal.currentUser?.team ?? "n/a"), radius: 3)

                RoundedRectangle(cornerRadius: 10)
                    .frame(width: (currentXp / maxXp) * 300, height: 20) // this scaled the green filled bar with the current xp compared to max xp
                    .foregroundColor(.green)
                    .animation(.easeInOut(duration: 1.5), value: currentXp) // animation to make look nice when filling up
                
                Text("XP: \(Int(currentXp)) / \(Int(maxXp))") // xp text
                    .font(.headline)
                    .frame(width: 300, height: 20, alignment: .center)
            }
        }
        .padding()
        .onAppear(){
            currentXp = UserLocal.currentUser?.xp ?? 0 // when page loads set current xp to that from userlocal
        }
    }
}

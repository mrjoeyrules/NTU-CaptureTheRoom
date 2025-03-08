//
//  ProgressView.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 08/03/2025.
//

import SwiftUI

struct CustomProgressView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.5) // Background overlay
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.actionColour)) // Custom color
                    .scaleEffect(1.5) // Makes it bigger
                
                Text("Loading...")
                    .foregroundColor(.white)
                    .font(.headline)
                    .bold()
            }
            .padding(30)
            .background(Color.background.opacity(0.8))
            .cornerRadius(15)
            .shadow(radius: 10)
        }
    }
}


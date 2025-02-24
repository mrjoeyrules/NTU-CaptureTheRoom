//
//  Nearby.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 26/01/2025.
//

import SwiftUI

struct Nearby: View {
    var body: some View {
        VStack{
            VStack{
                Text("Nearby Rooms")
                    .font(.title)
                    .fontWeight(.bold)
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background{
            Color.background
                .ignoresSafeArea()
        }
    }
    
}


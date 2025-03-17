//
//  Tutorial.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 17/03/2025.
//

import SwiftUI

struct Tutorial: View {
    
    let title: String
    let description: String
    let image: String
    
    
    var body: some View { // output whatever is needed
        VStack{
            
            
            Text(title) // title of tutorial
                .font(.headline)
                .foregroundColor(.textColour)
            
            Text(description) // value of stat
                .font(.subheadline)
                .foregroundColor(.textColour)
            
            Image(image)
                .frame(width: 30)
            
        }
        .padding(.vertical, 5)
    }
}

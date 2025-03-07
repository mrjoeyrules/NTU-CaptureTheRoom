//
//  UsersStats.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 07/03/2025.
//

import SwiftUI

struct UserStats: View {
    @State private var totalSteps: Int = 0
    @State private var dateJoined: String = ""
    @State private var totalXp: CGFloat = 0
    @State private var roomsCapped: Int = 0
    
    
    
    
    var body: some View {
        VStack{ // create an instance of statrow for each statistic being tracked
            StatRow(icon: "figure.walk", title: "Total Steps", value: "\(totalSteps) steps")
            StatRow(icon: "clock", title: "Date Joined", value: dateJoined)
            StatRow(icon: "medal.star", title: "Total XP Gained", value: "\(Int(totalXp)) xp")
            StatRow(icon: "house.and.flag", title: "Total Rooms Capped", value: "\(roomsCapped)")
        }
        .padding()
        .background(Color.background)
        .cornerRadius(15)
        .shadow(radius: 5)
        .padding(.horizontal, 20)
        .onAppear{
            getDataFromUserLocal()
        }
    }
    
    
    func getDataFromUserLocal(){
        totalSteps = UserLocal.currentUser?.totalSteps ?? 0
        dateJoined = UserLocal.currentUser?.dateJoined ?? ""
        totalXp = UserLocal.currentUser?.totalXp ?? 0
        roomsCapped = UserLocal.currentUser?.roomsCapped ?? 0
    }
}

struct StatRow: View { // custom views to display all the data needed, can be reused easily.
    let icon: String
    let title: String
    let value: String // pass through requred data
    
    var body: some View { // output whatever is needed
        HStack{
            Image(systemName: icon)
                .foregroundColor(Color.actionColour) // sf symbol icon
                .font(.title2)
                .frame(width: 30)
            
            Text(title) // title of stat
                .font(.headline)
                .foregroundColor(.textColour)
            
            Spacer() // space between
            
            Text(value) // value of stat
                .font(.headline)
                .foregroundColor(.green)
        }
        .padding(.vertical, 5)
    }
}


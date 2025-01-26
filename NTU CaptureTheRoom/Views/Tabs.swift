//
//  Tabs.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 26/01/2025.
//

import SwiftUI

struct Tabs: View {
    
    func prinTest(){
        print(UserLocal.currentUser?.username)
        print(UserLocal.currentUser?.level)
        print(UserLocal.currentUser?.team)
        print(UserLocal.currentUser?.xp)
        print(UserLocal.currentUser?.user)
    }
    
    
    @State var selectedTab: Tab = .maps
    enum Tab: Hashable {
        case profile
        case maps
        case nearby
    }
    var body: some View {
        TabView(selection: $selectedTab) {
            Profile()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(Tab.profile)

            Maps()
                .tabItem {
                    Label("Maps", systemImage: "map")
                }
                .tag(Tab.maps)

            Nearby()
                .tabItem {
                    Label("Nearby", systemImage: "mappin")
                }
                .tag(Tab.nearby)
        }
        .tint(Color.actionColour)
        .onAppear {
            // Explicitly set the selected tab when the view appears
            selectedTab = .maps
            prinTest()
        }
    }
}

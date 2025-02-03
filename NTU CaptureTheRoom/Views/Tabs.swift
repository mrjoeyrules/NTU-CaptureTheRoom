//
//  Tabs.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 26/01/2025.
//

import SwiftUI

struct Tabs: View {
    @State var selectedTab: Tab = .maps
    enum Tab: Hashable {
        case profile
        case maps
        case nearby
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
    }
}

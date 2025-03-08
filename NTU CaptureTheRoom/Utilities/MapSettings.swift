//
//  MapSettings.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 08/03/2025.
//

import SwiftUI

class MapSettings: ObservableObject{
    @Published var selectedTheme: MapTheme{
        didSet{
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: "selectedMapTheme")
        }
    }
    
    init(){
        let savedTheme = UserDefaults.standard.string(forKey: "selectedMapTheme") ?? MapTheme.systemDefault.rawValue
        self.selectedTheme = MapTheme(rawValue: savedTheme) ?? .systemDefault
    }
}

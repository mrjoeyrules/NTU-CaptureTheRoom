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
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: "selectedMapTheme") // store selected theme raw value in userdefaults under key selectedMapTheme
        }
    }
    
    init(){
        let savedTheme = UserDefaults.standard.string(forKey: "selectedMapTheme") ?? MapTheme.systemDefault.rawValue // get saved theme from userdefaults if nothing there used systemdefault which is light or dark. 
        self.selectedTheme = MapTheme(rawValue: savedTheme) ?? .systemDefault
    }
}

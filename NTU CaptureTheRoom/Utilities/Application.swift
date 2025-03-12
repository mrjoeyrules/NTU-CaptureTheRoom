//
//  Application.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 27/11/2024.
//

import SwiftUI

final class ApplicationUtility{
    static var rootViewController: UIViewController{
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else { // grabs the first active UIWINDOWSCENE
            return .init()
        }
        guard let root = screen.windows.first?.rootViewController else{ // Grabs the first window from the scene and gets the rootviewcontroller for that window
            return .init()
        }
        
        return root // returns the apps current rootview controller
    }
}

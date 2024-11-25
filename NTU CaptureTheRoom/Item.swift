//
//  Item.swift
//  NTU CaptureTheRoom
//
//  Created by Joseph Cuesta Acevedo on 25/11/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

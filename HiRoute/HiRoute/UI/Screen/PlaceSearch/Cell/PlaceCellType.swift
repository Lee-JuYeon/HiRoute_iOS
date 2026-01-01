//
//  SettingButton.swift
//  HiRoute
//
//  Created by Jupond on 12/18/25.
//

import SwiftUI

enum PlaceCellType : String, Codable {
    case HOT = "HOT"
    case NOMAL = "NOMAL"
    
    var displayText: String {
        return self.rawValue
    }
}


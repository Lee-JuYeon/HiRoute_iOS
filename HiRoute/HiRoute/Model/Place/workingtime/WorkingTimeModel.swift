//
//  FeedDetailScreen.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

struct WorkingTimeModel : Hashable, Codable, Identifiable {
    var id : String
    var dayTitle : String
    var open : String
    var close : String
    var lastOrder : String? = nil
  
}

extension WorkingTimeModel {
    static func convert12Hour(_ time: String) -> String { // static 함수로 변경
        // "1400" -> "2:00 PM" 형태로 변환
        guard time.count == 4,
              let hour = Int(time.prefix(2)),
              let minute = Int(time.suffix(2)) else {
            return time
        }
        
        let period = hour >= 12 ? "PM" : "AM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        
        return String(format: "%d:%02d %@", displayHour, minute, period)
    }
}

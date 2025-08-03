//
//  EventListView.swift
//  HiRoute
//
//  Created by Jupond on 7/1/25.
//

import SwiftUI

enum AppointmentTimeType: String, CaseIterable, Codable {
    case morning = "오전"
    case afternoon = "오후"
    case allDay = "하루종일"
    
    // 표시용 텍스트
    var displayText: String {
        return self.rawValue
    }
    
}

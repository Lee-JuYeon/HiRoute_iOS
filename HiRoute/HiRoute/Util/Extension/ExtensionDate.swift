//
//  HomePlaceListView.swift
//  HiRoute
//
//  Created by Jupond on 7/17/25.
//

import Foundation

extension Date {
    func toLocalizedDateString(region: NationalityType) -> String {
        let formatter = DateFormatter()
        
        switch region {
        case .korea:
            formatter.dateFormat = "yyyy년 M월 d일"
            formatter.locale = Locale(identifier: "ko_KR")
        case .japan:
            formatter.dateFormat = "yyyy年M月d日"
            formatter.locale = Locale(identifier: "ja_JP")
        case .europe:
            formatter.dateFormat = "dd/MM/yyyy"
            formatter.locale = Locale(identifier: "en_GB")
        case .northAmerica:
            formatter.dateFormat = "MM/dd/yyyy"
            formatter.locale = Locale(identifier: "en_US")
        case .southeastAsia:
            formatter.dateFormat = "dd/MM/yyyy"
            formatter.locale = Locale(identifier: "th_TH")
        }
        
        return formatter.string(from: self)
    }
}

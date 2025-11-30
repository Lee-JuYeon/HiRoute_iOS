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
        formatter.dateFormat = region.dateFormat

        
        switch region {
        case .KOREA:
            formatter.locale = Locale(identifier: "ko_KR")
        case .JAPAN:
            formatter.locale = Locale(identifier: "ja_JP")
        case .INDONESIA:
            formatter.locale = Locale(identifier: "id_ID")
        case .USA:
            formatter.locale = Locale(identifier: "en_US")
        case .MALAYSIA:
            formatter.locale = Locale(identifier: "ms_MY")
        case .SINGAPORE:
            formatter.locale = Locale(identifier: "en_SG")
        case .TAIWAN:
            formatter.locale = Locale(identifier: "zh_TW")
        }
        
        return formatter.string(from: self)
    }
}

//
//  OpeningHoursResponse.swift
//  HiRoute
//
//  Created by Jupond on 7/20/25.
//

struct OpeningHoursResponse: Codable {
    let openNow: Bool?
    let weekdayText: [String]?
    let periods: [PeriodResponse]?
    
    enum CodingKeys: String, CodingKey {
        case openNow = "open_now"
        case weekdayText = "weekday_text"
        case periods
    }
}

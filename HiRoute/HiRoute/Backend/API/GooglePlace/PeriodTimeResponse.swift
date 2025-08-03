//
//  PeriodTimeResponse.swift
//  HiRoute
//
//  Created by Jupond on 7/20/25.
//

struct PeriodTimeResponse: Codable {
    let day: Int        // 0: 일요일, 1: 월요일, ..., 6: 토요일
    let time: String    // "0800" 형식 (24시간)
}

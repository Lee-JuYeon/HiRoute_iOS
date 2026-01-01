//
//  RootDetailCountingTextView.swift
//  HiRoute
//
//  Created by Jupond on 7/23/25.
//

import SwiftUI

struct DdayCountingTextView: View {
    
    private var getDdayDate: Date
    init(
        setDdayDate: Date
    ) {
        self.getDdayDate = setDdayDate
    }
    
    private func countDday() -> Int {
        let currentDate = Date()
        let calendar = Calendar.current
        
        // 두 날짜 사이의 일수 계산
        let components = calendar.dateComponents([.day], from: currentDate, to: getDdayDate)
        
        return components.day ?? 0
    }
    
    private func getDdayText() -> String {
        let dday = countDday()
        
        if dday > 0 {
            return "일정까지 D-\(dday)일 남았어요"
        } else if dday == 0 {
            return "오늘이 D-Day예요!"
        } else {
            return "지난 일정입니다. 새로운 일정을 짜볼까요?"
        }
    }
    
    var body: some View {
        Text(getDdayText())
            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
            .font(.system(size: 12))
            .foregroundColor(Color.getColour(.background_white))
            .lineLimit(1)
            .background(Color.getColour(.label_strong))
            .cornerRadius(4)

    }
}

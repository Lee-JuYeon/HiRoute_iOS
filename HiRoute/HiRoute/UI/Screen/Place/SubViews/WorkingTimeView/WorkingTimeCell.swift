//
//  SelfieView.swift
//  HiRoute
//
//  Created by Jupond on 6/27/25.
//

import SwiftUI

struct WorkingTimeCell : View {
    
    private var model : WorkingTimeModel
    private var placeType: PlaceType
    
    init(
        setModel : WorkingTimeModel,
        setPlaceType: PlaceType
    ){
        self.model = setModel
        self.placeType = setPlaceType
    }
    
    private func formatWorkingTimeDisplay(_ workingTime: WorkingTimeModel) -> String {
        let openTime = WorkingTimeModel.convert12Hour(workingTime.open)
        let closeTime = WorkingTimeModel.convert12Hour(workingTime.close)
        
        var timeString = "\(workingTime.dayTitle) \(openTime) - \(closeTime)"
        
        // 식당 타입이고 lastOrder가 있는 경우
        if placeType == .restaurant, let lastOrder = workingTime.lastOrder {
            let lastOrderTime = WorkingTimeModel.convert12Hour(lastOrder)
            timeString += " (L.O \(lastOrderTime))"
        }
        
        return timeString
    }
    
    var body: some View {
        Text(formatWorkingTimeDisplay(model))
            .font(.system(size: 12))
            .foregroundColor(Color.getColour(.label_normal))
            .padding(.leading, 16)
    }
}


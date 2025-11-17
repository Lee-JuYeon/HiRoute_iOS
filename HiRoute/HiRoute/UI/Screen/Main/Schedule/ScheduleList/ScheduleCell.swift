//
//  HomePlaceChips.swift
//  HiRoute
//
//  Created by Jupond on 7/17/25.
//

import SwiftUI

struct ScheduleCell : View {

    private var getScheduleModel : ScheduleModel
    private var getUserNationality : NationalityType
    private var onClickCell : (ScheduleModel) -> Void
    init(
        setScheduleModel: ScheduleModel,
        setUserNationlity: NationalityType,
        setOnClickCell : @escaping (ScheduleModel) -> Void
    ) {
        self.getScheduleModel = setScheduleModel
        self.onClickCell = setOnClickCell
        self.getUserNationality = setUserNationlity
    }
    
    @ViewBuilder
    private func view(model : ScheduleModel) -> some View {
        let verticalSpacing : CGFloat = 12
        let horizontalSpacing : CGFloat = 8
        VStack(alignment:HorizontalAlignment.leading, spacing: verticalSpacing){
            Text(model.title)
                .font(.system(size: 16))
                .foregroundColor(.primary)
                .fontWeight(.bold)
                .lineLimit(1)
                .multilineTextAlignment(.leading)
            
            Text(model.memo)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            Text(model.d_day.toLocalizedDateString(region: getUserNationality))
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .multilineTextAlignment(.leading)
        }
        .padding(12) // ✅ 내부 패딩 추가
        .frame(
            maxWidth: .infinity,
            alignment: Alignment.leading
        )
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .customElevation(.normal)
        .overlay(
            // ✅ 1dp 회색 보더 추가
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.lineAlternative, lineWidth: 1)
        )
        .onTapGesture {
            onClickCell(model)
        }
    }
    
    var body: some View {
        view(model: getScheduleModel)
    }
}

//
//  Persistence.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//

import SwiftUI

struct PlanTopSection : View {
    
    private var getNationalityType : NationalityType
    
    init(
        setNationalityType : NationalityType,
    ) {
        self.getNationalityType = setNationalityType
    }
    
    @EnvironmentObject var scheduleVM: ScheduleViewModel

    @ViewBuilder
    private func dateView(_ date : Date) -> some View {
        return HStack(alignment:VerticalAlignment.center, spacing: 6) {
            Image("icon_calendar")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
                .foregroundColor(Color.getColour(.label_alternative))
            
            Text(date.toLocalizedDateString(region: getNationalityType))
                .font(.system(size: 14))
                .foregroundColor(Color.getColour(.label_alternative))
        }
        .padding(EdgeInsets(top: 0, leading: 16, bottom: 16, trailing: 16))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let selectedSchedule = scheduleVM.selectedSchedule {
                
                DdayCountingView(setDdayDate: selectedSchedule.d_day)
                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))

                PlanTitleView(title: selectedSchedule.title)
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))

                PlanMemoView(
                    setHint: "메모를 입력하세요",
                    setText: .constant(selectedSchedule.memo),
                    setOnClick: { newMemo in
                        scheduleVM.updateSchedule(<#T##schedule: ScheduleModel##ScheduleModel#>)
                        scheduleVM.updateSelectedScheduleMemo(newMemo)
                    }
                )
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
                
                dateView(selectedSchedule.d_day)
                
            } else {
                // ✅ 선택된 스케줄이 없을 때
                Text("스케줄을 불러올 수 없습니다")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.clear)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.getColour(.line_alternative), lineWidth: 1)
        )
        .customElevation(Elevation.normal)
        .cornerRadius(12)
        .padding(
            EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        )


    }
}

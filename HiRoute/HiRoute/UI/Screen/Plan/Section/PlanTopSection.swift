//
//  Persistence.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//

import SwiftUI

struct PlanTopSection : View {
    
    private var getNationalityType : NationalityType
    private var getModeType : ModeType
    
    init(
        setNationalityType : NationalityType,
        setModeType : ModeType
    ) {
        self.getNationalityType = setNationalityType
        self.getModeType = setModeType
    }
    
    @EnvironmentObject var scheduleVM: ScheduleVM

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
            
            offlineIndicator() // ✅ 추가: 오프라인 인디케이터

            if let selectedSchedule = scheduleVM.selectedSchedule {
                
                DdayCountingView(setDdayDate: selectedSchedule.d_day)
                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))

                PlanTitleView(title: selectedSchedule.title)
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))

                MultiLineMemoView(
                    setHint: "메모를 입력하세요",
                    setText: scheduleVM.scheduleMemomBinding,
                    setModeType : getModeType
                )
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
                
                dateView(selectedSchedule.d_day)
                
            } else {
                // ✅ 선택된 스케줄이 없을 때
                if scheduleVM.isLoading {
                    ProgressView("스케줄 로딩 중...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text("스케줄을 불러올 수 없습니다")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
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
        .onDisappear {
            // ✅ 수정: 오프라인에서도 로컬 저장
            if let memo = scheduleVM.selectedSchedule?.memo {
                scheduleVM.updateScheduleMemo(memo)
            }

        }
    }
}

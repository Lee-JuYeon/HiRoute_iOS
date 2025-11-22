//
//  ServerHeightImageView.swift
//  HiRoute
//
//  Created by Jupond on 7/5/25.
//
import SwiftUI

struct WorkingTimeList : View {
    
    private var list : [WorkingTimeModel]
    private var placeType: PlaceType
    
    init(
        setList : [WorkingTimeModel],
        setPlaceType: PlaceType
    ){
        self.list = setList
        self.placeType = setPlaceType
    }
    
    
    private func getTodayWorkingTime() -> String {
        let today = getTodayKoreanWeekday()
        
        if let todayWorkingTime = list.first(where: { $0.dayTitle == today }) {
            return formatWorkingTimeDisplay(todayWorkingTime)
        }
        
        return "\(today) 운영시간 정보 없음"
    }

    private func getOtherDaysWorkingTimes() -> [WorkingTimeModel] {
        let today = getTodayKoreanWeekday()
        let weekOrder = ["월", "화", "수", "목", "금", "토", "일"]
        
        // 오늘을 제외한 요일들을 순서대로 정렬
        return list
            .filter { $0.dayTitle != today }
            .sorted { first, second in
                let firstIndex = weekOrder.firstIndex(of: first.dayTitle) ?? 999
                let secondIndex = weekOrder.firstIndex(of: second.dayTitle) ?? 999
                return firstIndex < secondIndex
            }
    }
    
    private func getTodayKoreanWeekday() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "E" // 월, 화, 수 등
        return formatter.string(from: Date())
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
      
    
    
    @State private var expandableWorkingTimeList = false
    @State private var rotationAngle: Double = 0
    var body: some View {
        VStack(alignment: HorizontalAlignment.leading, spacing: 0){
            HStack(
                alignment: VerticalAlignment.top,
                spacing: 4
            ) {
                Image("icon_clock")
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(Color.getColour(.label_strong))
                    .aspectRatio(contentMode: ContentMode.fit)
                    .frame(width: 14, height: 14)
                
                Text(getTodayWorkingTime())
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_strong))
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
                
                Image("icon_arrow")
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(Color.getColour(.label_strong))
                    .aspectRatio(contentMode: ContentMode.fit)
                    .frame(width: 16, height: 16)
                    .rotationEffect(.degrees(90))
                    .rotationEffect(.degrees(expandableWorkingTimeList ? 0 : 180))
                    .animation(.easeInOut(duration: 0.3), value: expandableWorkingTimeList)
            }
            
            if expandableWorkingTimeList {
                ForEach(getOtherDaysWorkingTimes(), id: \.id) { workingTimeModel in
                    WorkingTimeCell(
                        setModel: workingTimeModel,
                        setPlaceType: placeType
                    )
                }
                .padding(
                    EdgeInsets(top: 8, leading: 18, bottom: 0, trailing: 0)
                )
            }
                
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.3)) {
                expandableWorkingTimeList.toggle()
            }
        }
        .padding(
            EdgeInsets(top: 0, leading: 12, bottom: 16, trailing: 0)
        )
        .frame(
            alignment: .topLeading
        )
    }
}

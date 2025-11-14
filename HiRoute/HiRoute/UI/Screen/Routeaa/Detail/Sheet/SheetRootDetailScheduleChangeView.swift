//
//  RootDetailScheduleView.swift
//  HiRoute
//
//  Created by Jupond on 7/23/25.
//

import SwiftUI

struct SheetRootDetailScheduleChangeView : View {
    
    private let getOnClickChangeSchedule : () -> Void
    private let getOnClickChangeSpot : () -> Void
    private let getOnClickChangeRootStyle : () -> Void
    private let getOnClickDeleteSchedule : () -> Void
    init(
        setOnClickChangeSchedule : @escaping () -> Void,
        setOnClickChangeSpot : @escaping () -> Void,
        setOnClickChangeRootStyle : @escaping () -> Void,
        setOnClickDeleteSchedule : @escaping () -> Void
    ){
        self.getOnClickChangeSchedule = setOnClickChangeSchedule
        self.getOnClickChangeSpot = setOnClickChangeSpot
        self.getOnClickChangeRootStyle = setOnClickChangeRootStyle
        self.getOnClickDeleteSchedule = setOnClickDeleteSchedule
    }
    
    @ViewBuilder
    private func title() -> some View {
        Text("일정 편집")
            .font(.system(size: 16))
            .foregroundColor(Color.getColour(.label_strong))
            .fontWeight(.bold)
            .lineLimit(1)
            .frame(
                maxWidth: .infinity,
                alignment: .center
            )
    }
    
    @ViewBuilder
    private func menuTitle(title : String, action :  @escaping () -> Void) -> some View {
        Text(title)
            .font(.system(size: 16))
            .foregroundColor(Color.getColour(.label_strong))
            .fontWeight(.bold)
            .lineLimit(1)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 0))
            .onTapGesture {
                action()
            }
    }
    
    var body: some View {
        VStack(
            alignment : HorizontalAlignment.center
        ){
            title()
            
            menuTitle(title: "일자 변경", action: getOnClickChangeSchedule)
            menuTitle(title: "장소 변경", action: getOnClickChangeSpot)
            menuTitle(title: "루트 스타일 추가", action: getOnClickChangeRootStyle)
            menuTitle(title: "일정 삭제", action: getOnClickDeleteSchedule)
        }
    }
}

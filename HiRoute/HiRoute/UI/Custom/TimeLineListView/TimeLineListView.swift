//
//  SheetFeedOptions.swift
//  HiRoute
//
//  Created by Jupond on 7/1/25.
//

import SwiftUI
import Foundation

struct TimeLineListView : View {
    
    private var planModel : PlanModel
    private var onClickRouteEdit : () -> Void
    private var onClickRouteAdd : () -> Void
    init(
        setPlanModel : PlanModel,
        setOnClickRouteEdit : @escaping () -> Void,
        setOnClickRouteAdd : @escaping () -> Void
    ){
        self.planModel = setPlanModel
        self.onClickRouteAdd = setOnClickRouteAdd
        self.onClickRouteEdit = setOnClickRouteEdit
    }
  

    // 날짜 포맷팅 함수
    private let formatter = DateFormatter()
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM월 dd일"
        formatter.locale = Locale(identifier: "ko_KR")  // 한국어 설정
        return formatter.string(from: date)
    }
    
    
    @ViewBuilder
    private func dateChip() -> some View {
        let horizontalInnerPadding: CGFloat = 12
        let verticalInnerPadding: CGFloat = 8
        let cornerRadius: CGFloat = 41
        let fontSize: CGFloat = 14
        let marginTop : CGFloat = 24
        
        let formattedDate = formatDate(planModel.meetingDate)
        Text(formattedDate)
            .font(.system(size: fontSize))
            .foregroundColor(Color.getColour(.label_strong))
            .fontWeight(.bold)
            .lineLimit(1)
            .padding(EdgeInsets(
                top: verticalInnerPadding,
                leading: horizontalInnerPadding,
                bottom: verticalInnerPadding,
                trailing: horizontalInnerPadding
            ))
            .background(Color.getColour(.background_white))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.getColour(.line_alternative), lineWidth: 1)
            )
            .customElevation(.normal)
            .padding(EdgeInsets(top: marginTop, leading: 0, bottom: 0, trailing: 0))
    }
    
    @ViewBuilder
    private func buttons() -> some View {
        let horizontalSpacing : CGFloat = 8
        let marginHorizontal : CGFloat = 16
        let verticalInnerPadding : CGFloat = 14
        let fontSize : CGFloat = 16
        let cornerRadius : CGFloat = 8
        HStack(alignment: VerticalAlignment.center, spacing: horizontalSpacing){
            Button {
                //action
            } label: {
                Text("장소 편집")
                    .font(.system(size: fontSize))
                    .foregroundColor(Color.getColour(.label_strong))
                    .fontWeight(.bold)
                    .background(Color.getColour(.background_white))
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.getColour(.label_strong), lineWidth: 1)
                    )
                    .padding(.vertical, verticalInnerPadding)
                    .onTapGesture {
                        onClickRouteEdit()
                    }
            }

            Button {
                //action
            } label: {
                Text("장소 추가")
                    .font(.system(size: fontSize))
                    .foregroundColor(Color.getColour(.background_white))
                    .fontWeight(.bold)
                    .padding(EdgeInsets(top: verticalInnerPadding, leading: verticalInnerPadding/2, bottom: verticalInnerPadding, trailing: verticalInnerPadding/2))
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color.getColour(.label_strong))
                    )
                    .onTapGesture {
                        onClickRouteAdd()
                    }
            }
        }
        .padding(
            EdgeInsets(
                top: 0,
                leading: marginHorizontal,
                bottom: 0,
                trailing: marginHorizontal
            )
        )
    }
    
    var body: some View {
        VStack(alignment: HorizontalAlignment.center){
            dateChip()
            
            if planModel.visitRoutes.count == 0 {
                // 장소가 비어있어요
            }else{
                // list
            }
            
            buttons()
            
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .top
        )
    }
    
}


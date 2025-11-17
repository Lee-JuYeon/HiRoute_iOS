//
//  Persistence.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//

import SwiftUI

struct PlanTopSection : View {
    
    private var getScheduleModel : ScheduleModel
    private var getNationalityType : NationalityType
    @Binding private var getMemoText : String
    
    init(
        setScheduleModel: ScheduleModel,
        setNationalityType : NationalityType,
        setMemoText: Binding<String>
    ) {
        self.getScheduleModel = setScheduleModel
        self.getNationalityType = setNationalityType
        self._getMemoText = setMemoText
    }

    @ViewBuilder
    private func dateView(_ date : Date) -> some View {
        return HStack(alignment:VerticalAlignment.center, spacing: 6) {
            Image("icon_calendar")
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
            
            DdayCountingView(setDdayDate: getScheduleModel.d_day)
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))
            
            

            PlanTitleView(title: getScheduleModel.title)
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))

            PlanMemoView(
                setHint: "힌트입니다",
                setText: $getMemoText,
                setOnClick: { text in
                    print("입력된 텍스트 : \(text)")
                }
            )
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16))
            
            dateView(getScheduleModel.d_day)


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

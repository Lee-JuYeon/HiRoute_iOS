//
//  CustomCalendarView.swift
//  HiRoute
//
//  Created by Jupond on 7/8/25.
//
import SwiftUI

struct PlaceInfoEditRequestView : View {
    
    let onCallBackInfoEditRequest : () -> Void
    
    
    var body: some View {
        HStack(alignment : VerticalAlignment.center, spacing: 4){
            Image("icon_edit")
                .renderingMode(.template)
                .resizable()
                .foregroundColor(Color.getColour(.label_alternative))
                .aspectRatio(contentMode: ContentMode.fit)
                .frame(width: 20, height: 20)
            
            Text("정보 수정 제안")
                .font(.system(size: 14))
                .foregroundColor(Color.getColour(.label_alternative))
            
            Image("icon_arrow_down")
                .renderingMode(.template)
                .resizable()
                .foregroundColor(Color.getColour(.label_alternative))
                .aspectRatio(contentMode: ContentMode.fit)
                .frame(width: 20, height: 20)
                .rotationEffect(.degrees(270))
        }
        .onTapGesture {
            onCallBackInfoEditRequest()
        }
        .padding(
            EdgeInsets(top: 0, leading: 12, bottom: 16, trailing: 12)
        )
    }
}


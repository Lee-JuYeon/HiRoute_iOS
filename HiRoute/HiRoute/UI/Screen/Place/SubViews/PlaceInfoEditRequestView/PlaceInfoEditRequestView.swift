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
        HStack(alignment : VerticalAlignment.center, spacing: 0){
            Image("icon_edit")
                .resizable()
                .foregroundColor(Color.getColour(.label_alternative))
                .aspectRatio(contentMode: ContentMode.fit)
                .frame(width: 16, height: 16)
            
            Text("정보 수정 제안")
                .font(.system(size: 12))
                .foregroundColor(Color.getColour(.label_alternative))
            
            Image("icon_arrow_down")
                .resizable()
                .foregroundColor(Color.getColour(.label_alternative))
                .aspectRatio(contentMode: ContentMode.fit)
                .frame(width: 12, height: 12)
                .rotationEffect(.degrees(270))
        }
        .onTapGesture {
            onCallBackInfoEditRequest()
        }
    }
}


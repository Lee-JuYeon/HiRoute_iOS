//
//  SimpleUserView.swift
//  HiRoute
//
//  Created by Jupond on 7/1/25.
//
import SwiftUI

struct SheetReviewListFilter : View {
    
    let onCallBackTypeClick : (ReviewListFilterType) -> Void
    
    @ViewBuilder
    private func button(type : ReviewListFilterType) -> some View {
        Button {
            onCallBackTypeClick(type)
        } label: {
            Text(type.displayText)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.getColour(.label_strong))
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(Color.getColour(.background_white))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.getColour(.line_alternative), lineWidth: 1)
                )
                .cornerRadius(12)
        }
        .customElevation(.normal)
        .padding(.horizontal, 16)
    }
    var body: some View {
        VStack(alignment: HorizontalAlignment.leading, spacing: 12){
            button(type: .new)
            button(type: .recommend)
            button(type: .manyStar)
            button(type: .littleStar)
           
        }
        .background(Color.getColour(.background_white))
        .padding(.vertical, 16)
    }
}

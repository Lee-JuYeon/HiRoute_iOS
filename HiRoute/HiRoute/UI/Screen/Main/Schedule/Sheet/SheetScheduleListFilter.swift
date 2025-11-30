//
//  SheetScheduleListFilter.swift
//  HiRoute
//
//  Created by Jupond on 11/29/25.
//

import SwiftUI


struct SheetScheduleListFilter: View {
    
    let onCallBackFilterType : (ListFilterType) -> Void
    
    @ViewBuilder
    private func button(type : ListFilterType) -> some View {
        Button {
            onCallBackFilterType(type)
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
            button(type: .NEWEST)
            button(type: .OLDEST)
        }
        .background(Color.getColour(.background_white))
        .padding(.vertical, 16)
    }
}

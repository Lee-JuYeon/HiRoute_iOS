//
//  ScheduleListEditButton.swift
//  HiRoute
//
//  Created by Jupond on 11/29/25.
//
import SwiftUI

struct ScheduleListEditButton : View {
    
    private let getOnClick: () -> Void
    init(
        setOnClick: @escaping () -> Void
    ){
        self.getOnClick = setOnClick
    }
    
    @State private var isOpen = false
    @ViewBuilder
    private func normalText() -> some View {
        Text("편집")
            .font(.system(size: 16))
            .foregroundColor(Color.getColour(.label_strong))
            .fontWeight(.light)
            .onTapGesture {
                getOnClick()
            }
    }
  
    
    var body: some View {
        normalText()
    }
}

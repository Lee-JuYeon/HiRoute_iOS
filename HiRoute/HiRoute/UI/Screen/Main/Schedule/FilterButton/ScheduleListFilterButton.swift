//
//  ScheduleListFilterButton.swift
//  HiRoute
//
//  Created by Jupond on 11/29/25.
//

import SwiftUI

struct ScheduleListFilterButton : View {
    
    private let getOnClick: (ListFilterType) -> Void
    init(
        setOnClick: @escaping (ListFilterType) -> Void
    ){
        self.getOnClick = setOnClick
    }
    
    @State private var isOpen = false
    @State private var text = ListFilterType.DEFAULT.displayText
    @ViewBuilder
    private func normalText() -> some View {
        Text(text)
            .font(.system(size: 16))
            .foregroundColor(Color.getColour(.label_strong))
            .fontWeight(.light)
            .onTapGesture {
                isOpen.toggle()
            }
    }
  
    
    var body: some View {
        normalText()
            .bottomSheet(isOpen: $isOpen) {
                SheetScheduleListFilter { listFilterType in
                    getOnClick(listFilterType)
                    isOpen.toggle()
                    text = listFilterType.displayText
                }
            }
    }
}

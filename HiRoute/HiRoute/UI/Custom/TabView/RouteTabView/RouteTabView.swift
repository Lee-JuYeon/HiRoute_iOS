//
//  RouteTabView.swift
//  HiRoute
//
//  Created by Jupond on 7/7/25.
//

import SwiftUI

struct RouteTabView<ContentView : View> : View {
    
    @Binding var tabViewIndex : Int
    let totalPage : Int
    let content: () -> ContentView

    
    init(
        tabViewIndex: Binding<Int>,
        totalPage: Int,
        @ViewBuilder content: @escaping () -> ContentView
    ) {
        self._tabViewIndex = tabViewIndex
        self.totalPage = totalPage
        self.content = content
    }
    
    @ViewBuilder
    private func indicator() -> some View {
        HStack(alignment : VerticalAlignment.center, spacing: 6){
            ForEach(0..<totalPage, id: \.self) { index in
                Circle()
                    .frame(width: 16, height: 16)
                    .foregroundColor(index == tabViewIndex ? Color.getColour(.label_strong) : Color.getColour(.label_disable))
                    .overlay(
                        Text("\(index + 1)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(index == tabViewIndex ? .white : Color.getColour(.label_assistive))
                    )
                    .animation(.easeInOut(duration: 0.2), value: tabViewIndex)
            }
            
            Spacer() // 왼쪽으로 쏠리게 하기 위한 Spacer
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 24, trailing: 0))
    }
    
    var body: some View {
        VStack(alignment:HorizontalAlignment.leading){
            indicator()
            
            Group {
                content()
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
        }
    }
}

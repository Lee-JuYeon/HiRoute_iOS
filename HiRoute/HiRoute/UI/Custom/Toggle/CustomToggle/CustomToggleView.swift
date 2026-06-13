//
//  CustomToggleView.swift
//  HiRoute
//
//  Created by Jupond on 2/12/26.
//
import SwiftUI

struct CustomToggleView: View {
    let items: [ToggleModel]
    let iconSize: CGFloat
    @Binding var selectedKey: String
    @Environment(\.colorScheme) var colorScheme

    // iconSize 기반 동적 사이즈
    private var circleSize: CGFloat { iconSize * 1.8 }
    private var buttonSize: CGFloat { iconSize * 2.2 }
    private var spacing: CGFloat { iconSize * 0.4 }
    private var totalWidth: CGFloat { buttonSize * CGFloat(items.count) + spacing * CGFloat(items.count - 1) + iconSize * 0.2 }
    private var totalHeight: CGFloat { buttonSize + iconSize * 0.4 }
    private var cornerRadius: CGFloat { totalHeight / 2 }

    // 선택된 아이템의 offset 계산
    private var selectedOffset: CGFloat {
        guard let index = items.firstIndex(where: { $0.key == selectedKey }) else { return 0 }
        let totalItemWidth = buttonSize + spacing
        let centerOfAll = totalItemWidth * CGFloat(items.count - 1) / 2
        return totalItemWidth * CGFloat(index) - centerOfAll
    }

    // 다크테마 색상
    private var backgroundColor: Color {
        colorScheme == .dark ? Color.black : Color.white
    }
    private var borderColor: Color {
        Color.gray.opacity(0.3)
    }
    private var selectedCircleColor: Color {
        colorScheme == .dark ? Color.white : Color.black
    }
    private var selectedIconColor: Color {
        colorScheme == .dark ? Color.black : Color.white
    }
    private var unselectedIconColor: Color {
        colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.6)
    }

    var body: some View {
        ZStack {
            // 슬라이딩 원형 배경
            Circle()
                .fill(selectedCircleColor)
                .frame(width: circleSize, height: circleSize)
                .offset(x: selectedOffset)

            // 아이콘 버튼들
            HStack(spacing: spacing) {
                ForEach(items, id: \.key) { item in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if selectedKey == item.key {
                                // 같은 곳 클릭 시 반대쪽으로 이동
                                if let currentIndex = items.firstIndex(where: { $0.key == item.key }) {
                                    let nextIndex = (currentIndex + 1) % items.count
                                    selectedKey = items[nextIndex].key
                                }
                            } else {
                                selectedKey = item.key
                            }
                        }
                    }) {
                        Image(item.icon)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: iconSize, height: iconSize)
                            .foregroundColor(
                                selectedKey == item.key ?
                                selectedIconColor : unselectedIconColor
                            )
                            .frame(width: buttonSize, height: buttonSize)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .frame(width: totalWidth, height: totalHeight)
        .background(backgroundColor)
        .cornerRadius(cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(borderColor, lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.2), value: selectedKey)
    }
}

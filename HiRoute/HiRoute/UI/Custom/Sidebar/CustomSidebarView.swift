//
//  CustomSidebarView.swift
//  HiRoute
//
//  Created by Jupond on 5/20/26.
//

import SwiftUI

/// 모바일 표준 overlay 사이드바 레이아웃 셸 (범용).
///
/// **왜 overlay인가 (push에서 변경)**:
/// push 방식(HStack)이면 사이드바 펼침 시 메인 컨텐츠 width = screen - sidebarWidth.
/// 모바일에선 main이 너무 좁아져 내용이 squeeze/잘림 (예: 393pt 화면 - 280pt 사이드바 = 113pt).
/// 모바일 표준(ChatGPT 등)은 overlay — 메인은 항상 풀스크린, 사이드바가 위로 슬라이드 인.
///
/// **동작**:
/// - main은 항상 풀스크린 유지
/// - 사이드바는 화면 밖에서 offset 슬라이드 in/out
/// - 펼침 시 백드롭(검은 반투명) 표시 → 백드롭 탭으로 닫힘
///
/// 사용 예:
/// ```
/// CustomSidebarView(isOpen: $isOpen, sidebarWidth: 280, edge: .leading) {
///     MySidebarContent()
/// } main: {
///     MyMainContent()
/// }
/// ```
struct CustomSidebarView<Sidebar: View, Main: View>: View {

    @Binding private var isOpen: Bool
    private let sidebarWidth: CGFloat
    private let edge: SidebarEdge
    private let sidebarBuilder: () -> Sidebar
    private let mainBuilder: () -> Main

    private let backdropOpacity: Double = 0.35
    private let slideAnimation: Animation = .easeInOut(duration: 0.22)

    init(
        isOpen: Binding<Bool>,
        sidebarWidth: CGFloat = 280,
        edge: SidebarEdge = .leading,
        @ViewBuilder sidebar: @escaping () -> Sidebar,
        @ViewBuilder main: @escaping () -> Main
    ) {
        self._isOpen = isOpen
        self.sidebarWidth = sidebarWidth
        self.edge = edge
        self.sidebarBuilder = sidebar
        self.mainBuilder = main
    }

    var body: some View {
        ZStack(alignment: zstackAlignment) {
            mainBuilder()

            backdrop

            sidebarLayer
        }
    }

    /// 메인 위에 까는 백드롭. 펼침 시 어둡게 + 탭하면 닫힘.
    private var backdrop: some View {
        Color.black
            .opacity(isOpen ? backdropOpacity : 0)
            .allowsHitTesting(isOpen)
            .onTapGesture {
                withAnimation(slideAnimation) {
                    isOpen = false
                }
            }
    }

    /// 사이드바 본체. edge에 따라 화면 밖 offset에서 슬라이드 인.
    private var sidebarLayer: some View {
        sidebarBuilder()
            .frame(width: sidebarWidth)
            .frame(maxHeight: .infinity)
            .overlay(divider, alignment: dividerAlignment)
            .offset(x: sidebarOffsetX)
    }

    private var sidebarOffsetX: CGFloat {
        switch edge {
        case .leading:  return isOpen ? 0 : -sidebarWidth
        case .trailing: return isOpen ? 0 : sidebarWidth
        }
    }

    private var divider: some View {
        Rectangle()
            .frame(width: 1)
            .foregroundColor(Color.getColour(.line_alternative))
    }

    /// 사이드바와 메인 컨텐츠가 맞닿는 쪽에 구분선을 둔다.
    private var dividerAlignment: Alignment {
        switch edge {
        case .leading: return .trailing
        case .trailing: return .leading
        }
    }

    /// ZStack alignment — 사이드바를 해당 edge에 붙임.
    private var zstackAlignment: Alignment {
        switch edge {
        case .leading: return .leading
        case .trailing: return .trailing
        }
    }
}

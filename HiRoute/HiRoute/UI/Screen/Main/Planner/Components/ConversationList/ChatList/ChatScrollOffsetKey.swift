//
//  ChatScrollOffsetKey.swift
//  HiRoute
//
//  [2026-06-08] 채팅 스크롤 오프셋 추적용 PreferenceKey.
//  MessageListView 내부 GeometryReader가 좌표공간 "chatScroll" 기준 minY를 보고,
//  PlannerView가 방향을 판정해 상단 chrome(topBar/storyBar)을 숨김/표시.
//
import SwiftUI

struct ChatScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

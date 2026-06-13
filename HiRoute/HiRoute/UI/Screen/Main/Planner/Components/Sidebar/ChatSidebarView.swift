//
//  ChatSidebarView.swift
//  HiRoute
//
//  Created by Jupond on 5/20/26.
//

import SwiftUI

/// 일정짜기 탭 전용 사이드바 컨텐츠.
/// 범용 SidebarListView를 조립하여 일정 목록을 구성한다 (채팅 == 일정).
struct ChatSidebarView: View {
    let schedules: [ScheduleModel]
    let currentScheduleUID: String?
    let onSelect: (String) -> Void
    let onDelete: (String) -> Void

    var body: some View {
        SidebarListView(
            sectionTitle: "일정",
            items: schedules,
            selectedID: currentScheduleUID,
            emptyConfig: SidebarEmptyConfig(
                iconName: "bubble.left.and.bubble.right",
                title: "아직 일정이 없어요",
                subtitle: "아래 입력창에 메시지를 보내보세요"
            ),
            onSelect: { onSelect($0.uid) },
            onDelete: { onDelete($0.uid) }
        )
        .background(Color.getColour(.background_alternative))
    }
}

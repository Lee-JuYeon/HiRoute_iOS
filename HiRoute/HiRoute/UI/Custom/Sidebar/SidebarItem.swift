//
//  SidebarItem.swift
//  HiRoute
//
//  Created by Jupond on 5/20/26.
//

/// SidebarListView가 기본 row를 그리기 위해 아이템이 제공해야 할 최소 정보.
protocol SidebarItem: Identifiable {
    /// row에 표시할 제목
    var sidebarTitle: String { get }
    /// row 좌측 SF Symbol 이름
    var sidebarIconName: String { get }
    /// 제목 아래 회색 작은 글씨로 표시할 부가 정보 (없으면 nil)
    var sidebarSubtitle: String? { get }
}

extension SidebarItem {
    /// 부가 정보가 필요 없는 아이템을 위한 기본값.
    var sidebarSubtitle: String? { nil }
}

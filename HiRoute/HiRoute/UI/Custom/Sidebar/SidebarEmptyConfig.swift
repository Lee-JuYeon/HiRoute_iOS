//
//  SidebarEmptyConfig.swift
//  HiRoute
//
//  Created by Jupond on 5/20/26.
//

/// SidebarListView 빈 상태 표시 설정.
struct SidebarEmptyConfig {
    let iconName: String
    let title: String
    let subtitle: String

    init(iconName: String, title: String, subtitle: String) {
        self.iconName = iconName
        self.title = title
        self.subtitle = subtitle
    }
}

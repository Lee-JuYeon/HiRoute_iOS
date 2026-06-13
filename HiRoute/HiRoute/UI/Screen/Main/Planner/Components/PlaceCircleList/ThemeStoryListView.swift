//
//  ThemeStoryListView.swift
//  HiRoute
//
//  Created by Jupond on 5/23/26.
//

import SwiftUI

/// 일정짜기 탭 상단 — 인스타 스토리 스타일 가로 스크롤 테마 큐레이션 바.
struct ThemeStoryListView: View {
    let stories: [ThemeStory]
    let onSelect: (ThemeStory) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(stories) { story in
                    PlaceCircleCell(
                        content: .symbol(
                            name: story.iconName,
                            tint: Color.getColour(.label_strong)
                        ),
                        title: story.title,
                        subtitle: nil,
                        onTap: { onSelect(story) }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color.getColour(.background_white))
    }
}

//
//  ThemeStory.swift
//  HiRoute
//
//  Created by Jupond on 5/23/26.
//

import Foundation

/// 일정짜기 탭 상단 스토리바에 노출되는 테마/스토리 큐레이션 항목.
struct ThemeStory: Identifiable, Hashable {
    let id: String
    let title: String
    /// 원형 썸네일에 표시할 SF Symbol 이름
    let iconName: String
    /// 탭 시 채팅에 전송할 프롬프트
    let prompt: String

    /// 더미 큐레이션 데이터. 추후 서버/서비스 연동 시 교체.
    static let samples: [ThemeStory] = [
        ThemeStory(id: "kdrama", title: "K-드라마 촬영지", iconName: "film",
                   prompt: "K-드라마 촬영지 위주로 여행 코스 짜줘"),
        ThemeStory(id: "palace", title: "고궁 산책", iconName: "building.columns",
                   prompt: "서울 고궁 위주로 일정 짜줘"),
        ThemeStory(id: "cafe", title: "성수동 카페", iconName: "cup.and.saucer",
                   prompt: "성수동 카페 투어 일정 짜줘"),
        ThemeStory(id: "hangang", title: "한강 나들이", iconName: "sun.max",
                   prompt: "한강 중심으로 여유로운 일정 짜줘"),
        ThemeStory(id: "nightview", title: "야경 명소", iconName: "moon.stars",
                   prompt: "서울 야경 명소 코스 짜줘"),
        ThemeStory(id: "market", title: "전통시장 미식", iconName: "fork.knife",
                   prompt: "서울 전통시장 미식 투어 짜줘")
    ]
}

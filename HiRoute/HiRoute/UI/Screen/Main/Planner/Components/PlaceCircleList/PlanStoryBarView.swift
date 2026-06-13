//
//  PlanStoryBarView.swift
//  HiRoute
//
//  Created by Jupond on 5/23/26.
//

import SwiftUI

/// 일정짜기 탭 상단 — 0번째 고정 "지도보기" + 추가된 PlanModel들을 인스타 스토리 스타일 가로 스크롤로 노출.
/// 모든 셀은 통일 `PlaceCircleCell`로 렌더.
/// - 0번째: SF Symbol(`map.fill`) + "지도보기"
/// - 1번째~: place 썸네일(URL) 또는 fallback SF Symbol + place 이름 + d_day
struct PlanStoryBarView: View {
    let plans: [PlanModel]
    let dDay: Date?
    let onSelect: (PlanModel) -> Void
    let onSelectMapShortcut: () -> Void

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter
    }()

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                PlaceCircleCell(
                    content: .symbol(
                        name: "map.fill",
                        tint: Color.getColour(.label_strong)
                    ),
                    title: "지도보기",
                    subtitle: nil,
                    onTap: onSelectMapShortcut
                )

                ForEach(plans) { plan in
                    PlaceCircleCell(
                        content: planContent(plan),
                        title: plan.placeModel.title,
                        subtitle: dDayText,
                        onTap: { onSelect(plan) }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color.getColour(.background_white))
    }

    private func planContent(_ plan: PlanModel) -> PlaceCircleContent {
        if let url = plan.placeModel.thumbnailImage?.imageUrl, !url.isEmpty {
            return .imageURL(url)
        } else {
            return .symbol(name: plan.placeModel.iconName, tint: plan.placeModel.iconColor)
        }
    }

    private var dDayText: String {
        guard let dDay = dDay else { return "방문 예정" }
        return Self.dateFormatter.string(from: dDay)
    }
}

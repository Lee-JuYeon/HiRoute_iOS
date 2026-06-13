//
//  PlaceCircleCell.swift
//  HiRoute
//
//  Created by Jupond on 5/25/26.
//

import SwiftUI

/// Nunulala 통일 원형 셀 (스토리 스타일).
/// PlanCircleView / StoryCircleView / MapShortcutCircleView 의 공통 뼈대를 합친 것.
/// 컨텐츠는 `PlaceCircleContent`로 SF Symbol 또는 이미지 URL 분기.
/// 링은 `line_normal` 회색 솔리드(미니멀). subtitle nil이어도 정렬 유지.
/// title/subtitle은 spacing 0으로 바싹 붙여 채팅 영역 더 확보.
struct PlaceCircleCell: View {
    let content: PlaceCircleContent
    let title: String
    let subtitle: String?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .strokeBorder(Color.getColour(.line_normal), lineWidth: 1.5)
                        .frame(width: 64, height: 64)

                    contentView
                        .frame(width: 54, height: 54)
                        .clipShape(Circle())
                }

                // 텍스트 두 개를 바싹 붙여 채팅 공간 확보
                VStack(spacing: 0) {
                    Text(title)
                        .font(.caption2)
                        .foregroundColor(Color.getColour(.label_neutral))
                        .lineLimit(1)
                        .frame(width: 66)

                    subtitleView
                }
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var contentView: some View {
        switch content {
        case .symbol(let name, let tint):
            Circle()
                .fill(Color.getColour(.fill_alternative))
                .overlay(
                    Image(systemName: name)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(tint)
                )
        case .imageURL(let url):
            ServerImageView(setImageURL: url)
        }
    }

    /// subtitle 없을 때도 정렬 맞춤용 invisible 라벨로 같은 높이 유지.
    @ViewBuilder
    private var subtitleView: some View {
        if let subtitle = subtitle {
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(Color.getColour(.label_assistive))
                .lineLimit(1)
        } else {
            Text(" ")
                .font(.caption2)
                .lineLimit(1)
        }
    }
}

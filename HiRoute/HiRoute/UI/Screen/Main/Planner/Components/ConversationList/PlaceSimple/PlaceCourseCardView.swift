//
//  PlaceCourseCardView.swift
//  HiRoute
//
//  Created by Jupond on 5/25/26.
//

import SwiftUI

/// AI가 추천 코스로 여러 장소를 한 번에 제안할 때 사용하는 묶음 카드.
/// 헤더 + 가로 스와이프 PageView(TabView .page style) + 인덱스 dots.
/// 단일 장소면 호출부가 PlaceInfoCardView를 직접 쓰면 됨.
struct PlaceCourseCardView: View {
    let places: [PlaceModel]
    let onSelect: (PlaceModel) -> Void

    @State private var currentIndex: Int = 0

    /// 페이지 높이 — PlaceInfoCardView(히어로 이미지 100 + 컨텐츠 + 패딩).
    /// 헤더 우측 "1 / 3" 카운터로 위치 표시하므로 하단 dots는 숨김.
    private let pageHeight: CGFloat = 220

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
            pager
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 6) {
            Image(systemName: "map.fill")
                .font(.caption.weight(.medium))
                .foregroundColor(Color.getColour(.primary_normal))

            Text("추천 코스 · \(places.count)곳")
                .font(.caption.weight(.semibold))
                .foregroundColor(Color.getColour(.label_strong))

            Spacer()

            Text("\(currentIndex + 1) / \(places.count)")
                .font(.caption2.weight(.medium))
                .foregroundColor(Color.getColour(.label_neutral))
        }
        .padding(.leading, 2)
    }

    // MARK: - Pager

    private var pager: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(places.enumerated()), id: \.element.id) { idx, place in
                PlaceInfoCardView(place: place, onTap: { onSelect(place) })
                    .tag(idx)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .frame(height: pageHeight)
    }
}

//
//  StreamingAssistantBubbleView.swift
//  HiRoute
//
//  Created by Jupond on 5/20/26.
//

import SwiftUI

/// 스트리밍 중인 assistant 메시지 — 일반 assistant 버블과 동일한 스타일(회색).
/// 도착한 attachedPlaces가 있으면 함께 노출.
struct StreamingAssistantBubbleView: View {
    let text: String
    let attachedPlaces: [PlaceModel]
    let onSelectPlace: (PlaceModel) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            bubble
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer(minLength: 48)
        }
        .padding(.horizontal, 16)
    }

    /// 텍스트 + 첨부 장소를 한 회색 버블 안에 묶어 노출.
    private var bubble: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !text.isEmpty {
                MarkdownTextView(text: text)
            }
            attachedPlacesView
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.getColour(.fill_strong))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    /// 2개 이상은 코스 카드, 1개면 단일 카드.
    @ViewBuilder
    private var attachedPlacesView: some View {
        if attachedPlaces.count >= 2 {
            PlaceCourseCardView(places: attachedPlaces, onSelect: onSelectPlace)
        } else if let place = attachedPlaces.first {
            PlaceInfoCardView(place: place, onTap: { onSelectPlace(place) })
        }
    }
}

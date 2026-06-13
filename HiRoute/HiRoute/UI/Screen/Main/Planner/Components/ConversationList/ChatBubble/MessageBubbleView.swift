//
//  MessageBubbleView.swift
//  HiRoute
//
//  Created by Jupond on 5/20/26.
//

import SwiftUI

/// PiPE 패턴 적용:
/// - user/assistant 둘 다 둥근 버블, 색만 다름 (user 어두움 / assistant 회색)
/// - assistant 버블 내부에 text + attachedPlaces 둘 다 포함 (한 덩어리로 응답을 보여줌):
///   - 1개: 단일 PlaceInfoCardView
///   - 2개 이상: PlaceCourseCardView (헤더 + 번호 배지 + 타임라인 연결선)
struct MessageBubbleView: View {
    let message: ChatMessageModel
    let onSelectPlace: (PlaceModel) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if message.role == .user {
                Spacer(minLength: 48)
                userBubble
            } else {
                assistantColumn
                Spacer(minLength: 48)
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - User

    private var userBubble: some View {
        Text(message.content)
            .font(.subheadline)
            .foregroundColor(Color.getColour(.background_white))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.getColour(.label_strong))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Assistant

    private var assistantColumn: some View {
        assistantBubble
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// 텍스트 + 첨부 장소를 한 회색 버블 안에 묶어 노출.
    private var assistantBubble: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !message.content.isEmpty {
                MarkdownTextView(text: message.content)
            }
            attachedPlacesView
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.getColour(.fill_strong))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    /// 2개 이상은 코스 카드, 1개면 단일 카드. 0개면 아무것도 안 그림.
    @ViewBuilder
    private var attachedPlacesView: some View {
        if let places = message.attachedPlaces, !places.isEmpty {
            if places.count >= 2 {
                PlaceCourseCardView(places: places, onSelect: onSelectPlace)
            } else if let place = places.first {
                PlaceInfoCardView(place: place, onTap: { onSelectPlace(place) })
            }
        }
    }
}

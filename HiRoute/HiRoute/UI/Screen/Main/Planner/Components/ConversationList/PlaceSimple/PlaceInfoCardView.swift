//
//  PlaceInfoCardView.swift
//  HiRoute
//
//  Created by Jupond on 5/24/26.
//

import SwiftUI

/// AI 채팅 응답에 첨부되는 "장소 간략히 보기" 카드.
/// 상단: 히어로 이미지 (썸네일 없으면 place 아이콘 fallback).
/// 하단: 좌측 accent bar(타입 색) + 배지(아이콘+타입 라벨) + 타이틀 + 부제 + 주소.
/// 탭 시 onTap 호출 — 상위에서 PlaceView로 네비게이션.
struct PlaceInfoCardView: View {
    let place: PlaceModel
    let onTap: () -> Void

    private let heroHeight: CGFloat = 100

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                heroImage
                HStack(alignment: .top, spacing: 12) {
                    accentBar
                    content
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
            }
            .background(Color.getColour(.background_white))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.getColour(.line_alternative), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Hero

    @ViewBuilder
    private var heroImage: some View {
        Group {
            if let imageUrl = place.thumbnailImage?.imageUrl, !imageUrl.isEmpty {
                ServerImageView(setImageURL: imageUrl)
            } else {
                placeIconFallback
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: heroHeight)
        .clipped()
    }

    private var placeIconFallback: some View {
        ZStack {
            place.iconColor.opacity(0.12)
            Image(systemName: place.iconName)
                .font(.system(size: 36, weight: .medium))
                .foregroundColor(place.iconColor.opacity(0.8))
        }
    }

    // MARK: - Info

    private var accentBar: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(place.iconColor)
            .frame(width: 4)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 4) {
            badge
            Text(place.title)
                .font(.subheadline.weight(.bold))
                .foregroundColor(Color.getColour(.label_strong))
                .lineLimit(2)
            if let subtitle = place.subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(Color.getColour(.label_neutral))
                    .lineLimit(1)
            }
            if let address = place.address.fullAddress, !address.isEmpty {
                Text(address)
                    .font(.caption2)
                    .foregroundColor(Color.getColour(.label_assistive))
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var badge: some View {
        HStack(spacing: 4) {
            Image(systemName: place.iconName)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(place.iconColor)
            Text(place.type.displayText)
                .font(.caption2.weight(.bold))
                .foregroundColor(place.iconColor)
        }
    }
}

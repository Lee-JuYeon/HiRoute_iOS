//
//  EmptyStateView.swift
//  HiRoute
//
//  Created by Jupond on 5/20/26.
//

import SwiftUI

struct EmptyStateView: View {
    let onTapSuggestion: (String) -> Void

    private let suggestions: [String] = [
        "3박 4일 서울 여행 짜줘",
        "혼자 가는 첫 한국 여행 일정",
        "K-드라마 촬영지 코스",
        "친구랑 갈 맛집 위주 일정"
    ]

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(Color.getColour(.primary_normal))

                Text("어떤 여행을 도와드릴까요?")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(Color.getColour(.label_strong))

                Text("간단한 요청만 적어주시면 맞춤 일정을 짜드려요")
                    .font(.subheadline)
                    .foregroundColor(Color.getColour(.label_neutral))
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 8) {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button(action: { onTapSuggestion(suggestion) }) {
                        HStack {
                            Text(suggestion)
                                .foregroundColor(Color.getColour(.label_normal))
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(Color.getColour(.label_assistive))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color.getColour(.fill_alternative))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)

            Spacer()
        }
    }
}

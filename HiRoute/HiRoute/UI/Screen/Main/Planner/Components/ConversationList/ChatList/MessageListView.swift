//
//  MessageListView.swift
//  HiRoute
//
//  Created by Jupond on 5/20/26.
//

import SwiftUI

struct MessageListView: View {
    let messages: [ChatMessageModel]
    let streamingText: String
    let streamingPlaces: [PlaceModel]
    let isStreaming: Bool
    let onSelectPlace: (PlaceModel) -> Void
    /// 스크롤 방향에 따른 상단 chrome 숨김 신호. true=숨김(아래로), false=표시(위로/최상단).
    var onScroll: (Bool) -> Void = { _ in }

    private let bottomAnchorID = "bottom_anchor"
    private let coordSpace = "chatScroll"
    /// 방향 판정 임계값(지터 방지) / 최상단 근처 강제표시 한계.
    private let threshold: CGFloat = 8
    private let topRevealZone: CGFloat = 40

    @State private var lastOffset: CGFloat = 0

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(messages) { message in
                        MessageBubbleView(message: message, onSelectPlace: onSelectPlace)
                            .id(message.uid)
                    }

                    if isStreaming {
                        if streamingText.isEmpty && streamingPlaces.isEmpty {
                            TypingIndicatorView()
                        } else {
                            StreamingAssistantBubbleView(
                                text: streamingText,
                                attachedPlaces: streamingPlaces,
                                onSelectPlace: onSelectPlace
                            )
                        }
                    }

                    Color.clear
                        .frame(height: 1)
                        .id(bottomAnchorID)
                }
                .padding(.vertical, 12)
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: ChatScrollOffsetKey.self,
                            value: geo.frame(in: .named(coordSpace)).minY
                        )
                    }
                )
            }
            .coordinateSpace(name: coordSpace)
            .onPreferenceChange(ChatScrollOffsetKey.self) { offset in
                handleScroll(offset)
            }
            .onChange(of: messages.count) { _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: streamingText) { _ in
                scrollToBottom(proxy: proxy, animated: false)
            }
            .onChange(of: streamingPlaces.count) { _ in
                scrollToBottom(proxy: proxy, animated: false)
            }
            .onAppear {
                scrollToBottom(proxy: proxy, animated: false)
            }
        }
    }

    /// 오프셋 변화량으로 스크롤 방향 판정. minY는 아래로 스크롤 시 감소(더 음수).
    private func handleScroll(_ offset: CGFloat) {
        // 최상단 근처면 무조건 표시.
        if offset > -topRevealZone {
            onScroll(false)
            lastOffset = offset
            return
        }
        let delta = offset - lastOffset
        if delta < -threshold {
            onScroll(true)        // 아래로 → 숨김
        } else if delta > threshold {
            onScroll(false)       // 위로 → 표시
        }
        lastOffset = offset
    }

    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool = true) {
        if animated {
            withAnimation(.easeOut(duration: 0.2)) {
                proxy.scrollTo(bottomAnchorID, anchor: .bottom)
            }
        } else {
            proxy.scrollTo(bottomAnchorID, anchor: .bottom)
        }
    }
}

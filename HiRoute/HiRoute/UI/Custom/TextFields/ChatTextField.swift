//
//  ChatTextField.swift
//  HiRoute
//
//  Created by Jupond on 5/20/26.
//

import SwiftUI

/// 채팅 입력바 — 텍스트필드 + 전송/취소 버튼.
/// 스트리밍 중엔 정지(stop) 버튼, 그 외엔 전송(arrow.up) 버튼.
struct ChatTextField: View {
    @Binding var text: String
    let isStreaming: Bool
    let onSend: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            // [2026-05-27 Phase C.8] AI 추천 정확성 disclaimer.
            Text("AI 추천은 참고용입니다. 영업·안전 정보는 직접 확인해주세요.")
                .font(.system(size: 10))
                .foregroundColor(Color.getColour(.label_assistive))
                .padding(.horizontal, 16)
                .multilineTextAlignment(.center)

            HStack(alignment: .bottom, spacing: 8) {
                TextField("무엇이든 물어보세요", text: $text)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.getColour(.fill_alternative))
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .foregroundColor(Color.getColour(.label_normal))

                Button(action: { isStreaming ? onCancel() : onSend() }) {
                    Image(systemName: isStreaming ? "stop.fill" : "arrow.up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(sendButtonBackground)
                        .clipShape(Circle())
                }
                .disabled(!isStreaming && !canSend)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .padding(.top, 6)
        .background(Color.getColour(.background_white))
    }

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var sendButtonBackground: Color {
        if isStreaming { return Color.getColour(.status_destructive) }
        return canSend ? Color.getColour(.label_strong) : Color.getColour(.interaction_disable)
    }
}

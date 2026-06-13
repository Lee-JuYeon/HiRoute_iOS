//
//  AILabelingToggleView.swift
//  HiRoute
//
//  Created by Jupond on 3/2/26.
//

import SwiftUI

/// AI 생성 이미지 라벨링 토글 뷰.
///
/// - 토글 ON: isAiGenerated = true (워터마크 적용 대상)
/// - 토글 OFF 시도 → 경고 다이얼로그 표시
/// - 경고 확인 → onForceOff 콜백 호출 (AI 생성 이미지 제거)
/// - iOS 14 호환: .tint → .toggleStyle, .alert(isPresented:) → .alert(isPresented:content:)
struct AILabelingToggleView: View {
    @Binding var isAiGenerated: Bool
    var onForceOff: () -> Void
    @State private var showWarning: Bool = false

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image("icon_ai")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .foregroundColor(
                    isAiGenerated
                    ? Color.getColour(.label_strong)
                    : Color.getColour(.label_alternative)
                )

            Text("AI 생성 이미지")
                .font(.system(size: 14))
                .foregroundColor(Color.getColour(.label_normal))

            Spacer()

            Toggle("", isOn: Binding(
                get: { isAiGenerated },
                set: { newValue in
                    if newValue {
                        isAiGenerated = true
                    } else {
                        showWarning = true
                    }
                }
            ))
            .labelsHidden()
            .toggleStyle(SwitchToggleStyle(tint: Color.getColour(.label_strong)))
        }
        .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    isAiGenerated
                    ? Color.getColour(.label_strong).opacity(0.08)
                    : Color.clear
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    isAiGenerated
                    ? Color.getColour(.label_strong).opacity(0.3)
                    : Color.getColour(.line_alternative),
                    lineWidth: 1
                )
        )
        .alert(isPresented: $showWarning) {
            Alert(
                title: Text("AI 생성 이미지 해제"),
                message: Text("AI 라벨링을 해제하면 AI 생성 이미지가 목록에서 제거됩니다."),
                primaryButton: .destructive(Text("해제")) {
                    isAiGenerated = false
                    onForceOff()
                },
                secondaryButton: .cancel(Text("취소"))
            )
        }
    }
}

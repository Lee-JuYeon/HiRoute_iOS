//
//  AIToggleCapsule.swift
//  HiRoute
//
//  Created by Jupond on 3/13/26.
//
import SwiftUI

/// 풀스크린 이미지 뷰어용 AI 라벨링 토글 캡슐.
/// 탭하면 `isAiGenerated` 토글. 활성 시 흰색 배경, 비활성 시 투명+흰색 테두리.
///
/// 사용처: ReviewWriteView 풀스크린 뷰어 상단 툴바
struct AIToggleCapsule: View {
    @Binding var isAiGenerated: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image("icon_ai")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)

            Text("AI")
                .font(.system(size: 12, weight: .bold))
        }
        .foregroundColor(isAiGenerated ? .black : .white.opacity(0.5))
        .padding(.horizontal, 12)
        .frame(height: 36)
        .background(
            Capsule()
                .fill(isAiGenerated ? Color.white : Color.clear)
        )
        .overlay(
            Capsule()
                .stroke(Color.white, lineWidth: isAiGenerated ? 0 : 1)
        )
        .contentShape(Capsule())
        .onTapGesture {
            isAiGenerated.toggle()
        }
    }
}

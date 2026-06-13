//
//  AIWatermarkView.swift
//  HiRoute
//
//  Created by Jupond on 3/3/26.
//

import SwiftUI

// MARK: - AIWatermarkSize

/// AI 워터마크 크기 프리셋.
/// - `.thumbnail`: 64~72pt 썸네일용 (아이콘 12, 배경 20, 패딩 2)
/// - `.normal`: 풀사이즈 이미지용 (아이콘 16, 배경 28, 패딩 6)


// MARK: - AIWatermarkModifier

/// 이미지 우측 하단에 AI 뱃지를 오버레이하는 ViewModifier.
/// `isAiGenerated == true`일 때만 표시.
///
/// 적용 대상: 유저 업로드 이미지 (리뷰 이미지, 파일 첨부 이미지)
/// 제외 대상: 앱 아이콘, 서버 장소 썸네일
private struct AIWatermarkModifier: ViewModifier {
    let isAiGenerated: Bool
    let size: AIWatermarkSize

    func body(content: Content) -> some View {
        ZStack(alignment: .bottomTrailing) {
            content

            if isAiGenerated {
                Image("icon_ai")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size.iconSize, height: size.iconSize)
                    .foregroundColor(Color.getColour(.background_white))
                    .frame(width: size.backgroundSize, height: size.backgroundSize)
                    .background(Circle().fill(Color.getColour(.label_strong)))
                    .padding(size.padding)
            }
        }
    }
}

// MARK: - View Extension

extension View {
    /// 유저 업로드 이미지에 AI 워터마크(우하단 뱃지) 오버레이.
    ///
    /// - Parameters:
    ///   - isAiGenerated: AI 생성 여부. `false`이면 뱃지 미표시.
    ///   - size: 뱃지 크기 프리셋. 기본값 `.thumbnail`.
    func aiWatermark(isAiGenerated: Bool, size: AIWatermarkSize = .thumbnail) -> some View {
        self.modifier(AIWatermarkModifier(isAiGenerated: isAiGenerated, size: size))
    }
}

// MARK: - AIToggleCapsule

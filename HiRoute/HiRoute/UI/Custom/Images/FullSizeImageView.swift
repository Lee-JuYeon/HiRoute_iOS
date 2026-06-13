//
//  FullSizeImageView.swift
//  HiRoute
//
//  Created by Jupond on 3/4/26.
//

import SwiftUI

/// 풀스크린 이미지 뷰어 공통 레이아웃.
/// 다크 배경 + 이미지 콘텐츠 + 닫기 버튼 + 선택적 trailing 툴바.
///
/// 사용처:
/// - FullSizeImageListView (서버 URL 이미지 다건 — TabView)
/// - ReviewWriteView (로컬 Data 이미지 단건 — ImageViewer + AIToggleCapsule)
/// - SheetReviewDetailView (서버 URL 이미지 다건 — TabView)
struct FullSizeImageView<Content: View, Trailing: View>: View {

    private let content: Content
    private let trailing: Trailing
    private let onClose: () -> Void

    init(
        onClose: @escaping () -> Void,
        @ViewBuilder trailing: () -> Trailing,
        @ViewBuilder content: () -> Content
    ) {
        self.onClose = onClose
        self.trailing = trailing()
        self.content = content()
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()

            content

            HStack {
                // 닫기 버튼
                ZStack {
                    Circle()
                        .fill(Color.black)

                    Circle()
                        .stroke(Color.white, lineWidth: 1)

                    Image("icon_close")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                        .foregroundColor(.white)
                }
                .frame(width: 36, height: 36)
                .contentShape(Circle())
                .onTapGesture {
                    onClose()
                }

                Spacer()

                trailing
            }
            .padding(EdgeInsets(top: 8, leading: 12, bottom: 0, trailing: 12))
        }
    }
}

// MARK: - Trailing 없는 convenience init

extension FullSizeImageView where Trailing == EmptyView {
    init(
        onClose: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.onClose = onClose
        self.trailing = EmptyView()
        self.content = content()
    }
}

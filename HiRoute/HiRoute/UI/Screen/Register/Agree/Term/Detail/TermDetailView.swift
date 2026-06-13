//
//  TermDetailView.swift
//  HiRoute
//
//  Created by Claude on 3/13/26.
//

import SwiftUI
import Combine
import WebKit

/// 약관 HTML 상세 보기 (WKWebView)
struct TermDetailView: View {

    let termTitle: String
    let termId: Int
    let onDismiss: () -> Void

    @State private var htmlContent: String = ""
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    @State private var termCancellable: AnyCancellable?

    var body: some View {
        VStack(spacing: 0) {
            // 상단바
            HStack {
                ImageButton(
                    imageUrl: "icon_back",
                    imageSize: 30
                ) {
                    onDismiss()
                }
                Spacer()
                Text(termTitle)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.getColour(.label_strong))
                    .lineLimit(1)
                Spacer()
                Color.clear.frame(width: 30, height: 30)
            }
            .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))

            Divider()

            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if let errorMessage = errorMessage {
                Spacer()
                Text(errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_alternative))
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            } else {
                TermHTMLWebView(htmlContent: htmlContent)
            }
        }
        .background(Color.getColour(.background_yellow_white))
        .onAppear {
            loadTermDetail()
        }
    }

    private func loadTermDetail() {
        guard termId > 0 else {
            errorMessage = "잘못된 요청입니다."
            isLoading = false
            return
        }

        let publisher: AnyPublisher<APIResponse<TermDetailData>, Error> =
            APIClient.shared.get(path: "/api/terms/\(termId)")

        termCancellable = publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                isLoading = false
                if case .failure = completion {
                    errorMessage = "약관을 불러올 수 없습니다."
                }
            }, receiveValue: { response in
                htmlContent = wrapHTML(response.data.contentHtml)
            })
    }

    private func wrapHTML(_ body: String) -> String {
        """
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <style>
            body {
                font-family: -apple-system, sans-serif;
                font-size: 15px;
                line-height: 1.6;
                color: #333;
                padding: 16px;
                margin: 0;
                word-break: keep-all;
            }
            h2 { font-size: 20px; margin-bottom: 16px; }
            p { margin-bottom: 12px; }
        </style>
        </head>
        <body>\(body)</body>
        </html>
        """
    }
}

// MARK: - WKWebView wrapper (iOS 14+)

// MARK: - Response DTO



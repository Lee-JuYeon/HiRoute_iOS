//
//  TermsOfUseView.swift
//  HiRoute
//
//  Created by Jupond on 5/6/26.
//

import SwiftUI
import Combine
import WebKit

struct PolicyContentURLData: Decodable {
    let termsUuid: String
    let downloadUrl: String
    let httpMethod: String
    let expiresAt: String
}

struct PolicyWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = false
        config.allowsInlineMediaPlayback = false
        config.websiteDataStore = .nonPersistent()

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.allowsLinkPreview = false
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if webView.url != url {
            webView.load(URLRequest(url: url))
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            if navigationAction.navigationType == .linkActivated {
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }
    }
}

struct PolicyHTMLWebView: UIViewRepresentable {
    let html: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = false
        config.allowsInlineMediaPlayback = false
        config.websiteDataStore = .nonPersistent()

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.allowsLinkPreview = false
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        if webView.url == nil {
            webView.loadHTMLString(html, baseURL: URL(string: SecretKeys.apiBaseURL))
        }
    }
}

struct PolicyDetailView: View {
    let termTitle: String
    let termId: Int
    let onDismiss: () -> Void

    @State private var contentURL: URL?
    @State private var contentHTML: String?
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    @State private var urlCancellable: AnyCancellable?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ImageButton(imageUrl: "icon_back", imageSize: 30) {
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
            } else if let errorMessage {
                Spacer()
                Text(errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_alternative))
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            } else if let contentURL {
                PolicyWebView(url: contentURL)
            } else if let contentHTML {
                PolicyHTMLWebView(html: contentHTML)
            } else {
                Spacer()
                Text("약관을 불러올 수 없습니다.")
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_alternative))
                Spacer()
            }
        }
        .background(Color.getColour(.background_yellow_white))
        .onAppear {
            loadContentURL()
        }
    }

    private func loadContentURL() {
        guard termId > 0 else {
            print("PolicyDetailView // invalid termId=\(termId)")
            errorMessage = "잘못된 요청입니다."
            isLoading = false
            return
        }

        let endpoint = "/api/terms/\(termId)/content-url"
        print("PolicyDetailView // request start: \(endpoint)")

        let publisher: AnyPublisher<APIResponse<PolicyContentURLData>, Error> =
            APIClient.shared.get(path: endpoint)

        urlCancellable = publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                isLoading = false
                if case .failure(let error) = completion {
                    print("PolicyDetailView // request failed: \(endpoint), error=\(error.localizedDescription)")
                    loadHTMLFallback()
                }
            }, receiveValue: { response in
                print("PolicyDetailView // request success: termsUuid=\(response.data.termsUuid), downloadUrl=\(response.data.downloadUrl), expiresAt=\(response.data.expiresAt)")
                contentURL = URL(string: response.data.downloadUrl)
                if contentURL == nil {
                    print("PolicyDetailView // invalid downloadUrl: \(response.data.downloadUrl)")
                    loadHTMLFallback()
                }
            })
    }

    private func loadHTMLFallback() {
        isLoading = true
        errorMessage = nil
        let endpoint = "/api/terms/\(termId)"
        print("PolicyDetailView // html fallback start: \(endpoint)")

        let publisher: AnyPublisher<APIResponse<TermDetailData>, Error> =
            APIClient.shared.get(path: endpoint)

        urlCancellable = publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("PolicyDetailView // html fallback failed: \(endpoint), error=\(error.localizedDescription)")
                    errorMessage = "약관을 불러올 수 없습니다."
                    isLoading = false
                }
            }, receiveValue: { response in
                print("PolicyDetailView // html fallback success: termId=\(response.data.id), title=\(response.data.title)")
                contentHTML = response.data.contentHtml
                isLoading = false
            })
    }
}

struct TermsOfUseView: View {
    let termTitle: String
    let termId: Int
    let onDismiss: () -> Void

    var body: some View {
        PolicyDetailView(termTitle: termTitle, termId: termId, onDismiss: onDismiss)
    }
}

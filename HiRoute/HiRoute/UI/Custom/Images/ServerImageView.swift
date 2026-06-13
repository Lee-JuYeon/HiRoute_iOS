//
//  ServerImageView.swift
//  HiRoute
//
//  Created by Jupond on 7/2/25.
//

import SwiftUI

struct ServerImageView : View {
    
    let imageUrl : String

    init(
        setImageURL: String,
    ) {
        self.imageUrl = setImageURL
    }
    
    // URLSession + Combine 사용
    @State private var image: UIImage?
    @State private var isLoading: Bool = false
    
    // Static cache for all instances
    private static let cache = NSCache<NSString, UIImage>()
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        
        let cacheKey = NSString(string: urlString)
        
        // 캐시에서 확인
        if let cachedImage = Self.cache.object(forKey: cacheKey) {
            self.image = cachedImage
            self.isLoading = false
            return
        }
        
        // 이미 로딩 중이면 중복 요청 방지
        guard !isLoading else { return }
        
        isLoading = true

        // [SEC] 첫-파티(api.nunulala.com)는 핀된 세션 경유(MITM 방어), 서드파티 CDN은 일반 세션.
        // (핀된 세션은 서드파티 호스트의 핀 불일치로 거부하므로 호스트별 분기 필수.)
        let session = PinnedURLSessionProvider.isFirstParty(url)
            ? PinnedURLSessionProvider.shared.imageSession
            : URLSession.shared
        session.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let data = data, let uiImage = UIImage(data: data) {
                    Self.cache.setObject(uiImage, forKey: cacheKey)
                    self.image = uiImage
                } else {
                    // 로딩 실패 시 placeholder 상태 유지
                    self.image = nil
                }
            }
        }.resume()
    }
    
    var body: some View {
        // 첫-파티(api.nunulala.com)는 AsyncImage(.shared, 핀 불가) 대신 핀된 세션 수동 로더 사용.
        // 서드파티 CDN은 iOS 15+에서 AsyncImage 허용(핀 대상 아님).
        if PinnedURLSessionProvider.isFirstParty(URL(string: imageUrl)) {
            manualLoaderView
        } else if #available(iOS 15.0, *) {
            AsyncImage(url: URL(string: imageUrl)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                case .failure(_):
                    errorView
                case .empty:
                    loadingView
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            manualLoaderView
        }
    }

    private var manualLoaderView: some View {
        Group {
            if let image = image {
                successView(image)
            } else if isLoading {
                loadingView
            } else {
                errorView
            }
        }
        .onAppear {
            loadImage(from: imageUrl)
        }
        .onChange(of: imageUrl) { newURL in
            image = nil
            isLoading = false
            loadImage(from: newURL)  // 직접 사용
        }
    }
    
    private var loadingView: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .overlay(
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(0.8)
            )
    }
    
    private func successView(_ uiImage: UIImage) -> some View {
        Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .clipped()
    }

    private var errorView: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.15))
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 24))
                    .foregroundColor(Color.gray.opacity(0.5))
            )
    }
}

//
//  ServerImageView.swift
//  HiRoute
//
//  Created by Jupond on 7/2/25.
//

import SwiftUI

struct ServerImageView : View {
    
    let imageURL : String

    init(
        setImageURL: String,
    ) {
        self.imageURL = setImageURL
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
        
        URLSession.shared.dataTask(with: url) { data, response, error in
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
        if #available(iOS 15.0, *) {
            AsyncImage(url: URL(string: imageURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipped()
                case .failure(_):
                    errorView
                case .empty:
                    loadingView
                @unknown default:
                    EmptyView()
                }
            }
        }else{
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
                loadImage(from: imageURL)
            }
            .onChange(of: imageURL) { newURL in
                image = nil
                isLoading = false
                loadImage(from: newURL)  // 직접 사용
            }
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
            .aspectRatio(contentMode: .fit)
            .clipped()
    }
    
    private let placeHolder : String = ""
    private var errorView: some View {
        Image(placeHolder)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .clipped()

    }
}

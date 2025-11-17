//
//  SelfieView.swift
//  HiRoute
//
//  Created by Jupond on 6/27/25.
//

import SwiftUI

struct SelfieView : View {
    let imageURL: String?
    let size: CGFloat
    let placeholderIcon: String
    let backgroundColor: Color
    
    @State private var image: UIImage?
    @State private var isLoading: Bool = false
    
    // Static cache for all instances
    private static let cache = NSCache<NSString, UIImage>()
    
    init(
        imageURL: String?,
        size: CGFloat = 60,
        placeholderIcon: String = "person.fill",
        backgroundColor: Color = .gray
    ) {
        self.imageURL = imageURL
        self.size = size
        self.placeholderIcon = placeholderIcon
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else if isLoading {
                ProgressView()
                    .frame(width: size, height: size)
                    .background(backgroundColor)
                    .clipShape(Circle())
            } else {
                Image(systemName: placeholderIcon)
                    .font(.system(size: size * 0.4))
                    .foregroundColor(.white)
                    .frame(width: size, height: size)
                    .background(backgroundColor)
                    .clipShape(Circle())
            }
        }
        .onAppear {
            if let urlString = imageURL {
                loadImage(from: urlString)
            }
        }
        .onChange(of: imageURL) { newURL in
            if let urlString = newURL {
                loadImage(from: urlString)
            } else {
                image = nil
                isLoading = false
            }
        }
    }
    
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
}


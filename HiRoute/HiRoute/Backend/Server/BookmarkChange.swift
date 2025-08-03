//
//  BookmarkChange.swift
//  HiRoute
//
//  Created by Jupond on 7/29/25.
//

// 북마크 변경 추적 모델
struct BookmarkChange: Codable {
    let routeUID: String
    let isBookmarked: Bool
  
    init(routeUID: String, isBookmarked: Bool) {
        self.routeUID = routeUID
        self.isBookmarked = isBookmarked
    }
}

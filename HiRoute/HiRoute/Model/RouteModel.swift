//
//  RouteModel.swift
//  HiRoute
//
//  Created by Jupond on 6/26/25.
//

import Foundation

struct RouteModel : Hashable, Codable { // 지금 인기있는 장소, 지역 맞춤 장소
    var routeUID : String // 루트 uid
    var routeType : String // 루트 분류 (테마)
    var routeTitle : String // 루트 이름 (장소이름)
    var routeMemo : String? // 루트 메모
    var address : AddressModel // 루트 위치
    var thumbNailImageURL : String // 썸네일 이미지
    var images : [String] // 이미지 최대 5장
    var workingTimes : [WorkingTimeModel] // 운영시간
    var reviews : [ReviewModel] // 리뷰

    var totalStarCount: Int        // 총 별점 수만 저장
    var totalBookmarkCount: Int    // 총 북마크 수만 저장
    
    var isBookmarkedLocally: Bool = false  // UI에서 사용할 북마크 상태 (로컬 전용)
    
    // 시작시간
    init(
        routeUID : String,
        routeType : String,
        routeTitle : String,
        routeMemo : String? = nil,
        address : AddressModel,
        thumbNailImageURL : String = "",
        images : [String] = [],
        workingTimes : [WorkingTimeModel] = [],
        reviews : [ReviewModel] = [],
        totalStarCount: Int = 0 ,      // 총 별점 수만 저장
        totalBookmarkCount: Int = 0,   // 총 북마크 수만 저장
        isBookmarkedLocally : Bool = false
    ){
        self.routeUID = routeUID
        self.routeType = routeType
        self.routeTitle = routeTitle
        self.routeMemo = routeMemo
        self.address = address
        self.thumbNailImageURL = thumbNailImageURL
        self.images = images
        self.workingTimes = workingTimes
        self.reviews = reviews
        self.totalStarCount = totalStarCount
        self.totalBookmarkCount = totalBookmarkCount
        self.isBookmarkedLocally = isBookmarkedLocally
    }
}


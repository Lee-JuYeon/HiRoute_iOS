//
//  AnnotationModel.swift
//  HiRoute
//
//  Created by Jupond on 7/20/25.
//
import SwiftUI
import CoreLocation

struct PlaceModel: Codable {
    let uid: String
    let address: AddressModel // 주소
    let type: AnnotationType
    let title: String // api 제공
    let subtitle: String? // api제공
    let thumbanilImageURL : String? // 썸네일 이미지 주소
    let imageURLs : [String] // 이미지 최대 5장
    
    var workingTimes : [WorkingTimeModel] // 운영시간
    var reviews : [ReviewModel] // 리뷰
    
    var totalStarCount: Int        // 총 별점 수만 저장
    var totalBookmarkCount: Int    // 총 북마크 수만 저장
    
    var isBookmarkedLocally: Bool = false  // UI에서 사용할 북마크 상태 (로컬 전용)
    
    
    var iconName: String {
        switch type {
        case .hospital: return "cross.fill"
        case .store: return "cart.fill"
        case .restaurant: return "fork.knife"
        case .cafe: return "cup.and.saucer.fill"
        }
    }
    
    var iconColor: Color {
        switch type {
        case .hospital: return .red
        case .store: return .blue
        case .restaurant: return .orange
        case .cafe: return .purple
        }
    }
}

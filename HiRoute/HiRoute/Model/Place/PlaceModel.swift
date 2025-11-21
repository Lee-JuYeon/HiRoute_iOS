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
    let type: PlaceType
    let title: String // api 제공
    let subtitle: String? // api제공
    let thumbanilImageURL : String? // 썸네일 이미지 주소
    let imageURLs : [String] // 이미지 최대 5장
    
    var workingTimes : [WorkingTimeModel] // 운영시간
    var reviews : [ReviewModel] // 리뷰
    
    var bookMarks : [BookMarkModel] // 북마크한 유저 uid리스트
    var stars : [StarModel] // 별점 리스트
    
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

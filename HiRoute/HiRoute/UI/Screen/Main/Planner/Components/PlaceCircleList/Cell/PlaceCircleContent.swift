//
//  PlaceCircleContent.swift
//  HiRoute
//
//  Created by Jupond on 5/25/26.
//

import SwiftUI

/// PlaceCircleCell의 내부 컨텐츠 종류.
/// - symbol: SF Symbol 아이콘 (테마/지도보기 셀용)
/// - imageURL: 원격 이미지 URL (plan 썸네일용)
enum PlaceCircleContent {
    case symbol(name: String, tint: Color)
    case imageURL(String)
}

//
//  PlaceSearchState.swift
//  HiRoute
//
//  Created by Jupond on 12/23/25.
//

enum PlaceSearchState {
    case initial     // 초기 상태 (추천 표시)
    case searching   // 검색 중
    case completed   // 검색 완료 (결과 표시)
    case empty // 겸색결과 없음
    
    var showRecommendations: Bool {
        return self == .initial
    }
    
    var showSearchResults: Bool {
        return self == .completed
    }
}

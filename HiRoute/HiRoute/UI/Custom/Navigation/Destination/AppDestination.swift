//
//  AppDestination.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//

enum AppDestination {
    // 인증 플로우
    case splash
    case onBoarding
    case register

    // 메인
    case main

    // Schedule → Plan → Place 흐름
    case plan
    case place
    case placeSearch

    // Place 하위
    case searchRoute
    case pictureList
    case reviewWrite

    // MyPage 하위
    case myReviews
    case myBookmarks
    case myUsefuls

}

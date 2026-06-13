//
//  NavigationVM.swift
//  HiRoute
//
//  Created by Jupond on 6/28/25.
//
import SwiftUI

class NavigationVM : ObservableObject {

    @Published var destination : AppDestination = .splash
    @Published var currentModeType : ModeType = .READ
    @Published var currentPlaceModeType : PlaceModeType = .MY
    // [2026-05-26] 일정/지도 탭 숨김 → 기본 탭을 .planner로. .map/.schedule 태그로 selection이
    // 가도 매칭되는 visible tab이 없어 빈 화면 보임.
    @Published var mainTabIndex : MainDestination = .planner

    private var navigationStack : [AppDestination] = []

    func navigateTo(setDestination : AppDestination){
        navigationStack.append(destination)
        destination = setDestination
    }

    func goBack(){
        if let previous = navigationStack.popLast() {
            destination = previous
        }
    }

    @Published var registerTabIndex : Int = 0
}

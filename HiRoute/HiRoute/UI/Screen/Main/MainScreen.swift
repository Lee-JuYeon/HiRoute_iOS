//
//  MainScreen.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

struct MainScreen: View {

    @EnvironmentObject private var navigationVM : NavigationVM

    var body: some View {
        TabView(selection: $navigationVM.mainTabIndex) {
            PlannerView()
                .environmentObject(navigationVM)
                .tabItem {
                    Image(systemName: MainDestination.planner.icon)
                    Text(MainDestination.planner.title)
                }
                .tag(MainDestination.planner)

            // [2026-05-26] 일정/지도 기능은 일정짜기 탭에 통합됨 (PlanStoryBar + ScheduleFullscreenMapView).
            // 바텀탭에서만 숨김. HomeView/ScheduleView 파일 자체는 유지 (재사용/롤백 대비).
            //
            // HomeView()
            //     .environmentObject(navigationVM)
            //     .tabItem {
            //         Image(systemName: MainDestination.map.icon)
            //         Text(MainDestination.map.title)
            //     }
            //     .tag(MainDestination.map)
            //
            // ScheduleView()
            //     .environmentObject(navigationVM)
            //     .navigationViewStyle(StackNavigationViewStyle())
            //     .tabItem {
            //         Image(systemName: MainDestination.schedule.icon)
            //         Text(MainDestination.schedule.title)
            //     }
            //     .tag(MainDestination.schedule)

            MyPageView()
                .navigationViewStyle(StackNavigationViewStyle())
                .tabItem {
                    Image(systemName: MainDestination.myPage.icon)
                    Text(MainDestination.myPage.title)
                }
                .tag(MainDestination.myPage)
        }
        .accentColor(Color.getColour(.label_strong))
//        .overlay(
//            // 오프라인 상태 알림
//            OfflineIndicatorView(isVisible: networkStatus == .offline),
//            alignment: .top
//        )
        .onAppear {
//            setupNetworkMonitoring()
//            loadInitialDataIfNeeded()
        }
    }
}

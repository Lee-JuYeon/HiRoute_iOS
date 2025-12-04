//
//  HiRouteApp.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//

import SwiftUI

@main
struct HiRouteApp: App {
    
    // ServiceContainer 활용으로 Service 인스턴스 공유 ✅
    @StateObject private var scheduleVM = ScheduleVM(
        scheduleService: ServiceContainer.shared.scheduleService
    )
    @StateObject private var planVM = PlanVM(
        scheduleService: ServiceContainer.shared.scheduleService,  // 같은 인스턴스 공유
        placeService: ServiceContainer.shared.placeService
    )
    @StateObject private var placeVM = PlaceVM(
        placeService: ServiceContainer.shared.placeService,        // 같은 인스턴스 공유
        bookmarkService: ServiceContainer.shared.bookMarkService,
        reviewService: ServiceContainer.shared.reviewService,
        starService: ServiceContainer.shared.starService
    )
    @StateObject private var localVM = LocalVM()
    
    var body: some Scene {
        WindowGroup {
            AppNavigationView()
                .environmentObject(scheduleVM)
                .environmentObject(planVM)
                .environmentObject(placeVM)
                .environmentObject(localVM)
        }
    }
}

//
//  HiRouteApp.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//

import SwiftUI

@main
struct HiRouteApp: App {
    
    // ServiceContainer로 통합 관리
    private let serviceContainer = ServiceContainer.shared
    
    // ViewModel들은 ServiceContainer에서 Service 주입
    @StateObject private var scheduleVM = ScheduleVM(
        scheduleService: ServiceContainer.shared.scheduleService
    )
    
    @StateObject private var planVM = PlanVM(
        planService: ServiceContainer.shared.planService
    )
    
    @StateObject private var placeVM = PlaceVM(
        placeService: ServiceContainer.shared.placeService,
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

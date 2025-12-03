//
//  HiRouteApp.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//

import SwiftUI

@main
struct HiRouteApp: App {
    
    // Service 인스턴스들을 미리 생성 (공유용)
    private let scheduleService = ScheduleService(repository: ScheduleRepository())
    private let placeService = PlaceService(repository: PlaceRepository())
    private let bookmarkService = BookMarkService(repository: BookMarkRepository())
    private let reviewService = ReviewService(repository: ReviewRepository())
    private let starService = StarService(repository: StarRepository())
    
    @StateObject private var scheduleVM: ScheduleVM
    @StateObject private var planVM: PlanVM
    @StateObject private var placeVM: PlaceVM
    @StateObject private var localVM = LocalVM()
    
    init() {
        // 같은 Service 인스턴스를 공유
        self._scheduleVM = StateObject(wrappedValue:
            ScheduleViewModel(scheduleService: scheduleService)
        )
        self._planVM = StateObject(wrappedValue:
            PlanViewModel(scheduleService: scheduleService, placeService: placeService)
        )
        self._placeVM = StateObject(wrappedValue:
            PlaceViewModel(
                placeService: placeService,
                bookmarkService: bookmarkService,
                reviewService: reviewService,
                starService: starService
            )
        )
    }
    
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


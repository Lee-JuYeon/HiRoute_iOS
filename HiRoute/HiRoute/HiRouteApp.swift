//
//  HiRouteApp.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//

import SwiftUI
import GoogleSignIn
import LineSDK

@main
struct HiRouteApp: App {

    // ServiceContainer로 통합 관리
    private let serviceContainer = ServiceContainer.shared

    init() {
        LoginManager.shared.setup(channelID: SecretKeys.lineChannelID, universalLinkURL: nil)
        // [2026-05-26 Phase 3] soft-deleted row 가비지 컬렉터.
        // 7일 grace period 지난 항목 정리. 내부 throttling으로 1일 1회만 실행.
        GCService.shared.runIfDue()
    }
    
    // ViewModel들은 ServiceContainer에서 Service 주입
    @StateObject private var scheduleVM = ScheduleVM(
        scheduleService: ServiceContainer.shared.scheduleService,
        planService: ServiceContainer.shared.planService
    )
    
    @StateObject private var placeVM = PlaceVM(
        placeService: ServiceContainer.shared.placeService,
        bookmarkService: ServiceContainer.shared.bookMarkService,
        reviewService: ServiceContainer.shared.reviewService,
        starService: ServiceContainer.shared.starService,
        guideService: ServiceContainer.shared.guideService
    )

    @StateObject private var audioPlayerVM = AudioPlayerVM()
    
    @StateObject private var localVM = LocalVM()

    @StateObject private var userVM = UserVM(
        userService: ServiceContainer.shared.userService
    )

    @StateObject private var navigationVM = NavigationVM()

    @StateObject private var chatVM = ChatVM(
        chatService: ServiceContainer.shared.chatService,
        scheduleService: ServiceContainer.shared.scheduleService
    )

    var body: some Scene {
        WindowGroup {
            AppNavigationView()
                .environmentObject(navigationVM)
                .environmentObject(scheduleVM)
                .environmentObject(placeVM)
                .environmentObject(localVM)
                .environmentObject(userVM)
                .environmentObject(audioPlayerVM)
                .environmentObject(chatVM)
                .onOpenURL { url in
                    if LoginManager.shared.application(.shared, open: url) {
                        return
                    }
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}

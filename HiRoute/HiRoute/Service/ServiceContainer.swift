//
//  ServiceContainer.swift
//  HiRoute
//
//  Created by Jupond on 11/26/25.
//

import Foundation

class ServiceContainer {

    // MARK: - Lazy Services
    lazy var scheduleService: ScheduleService = {
        ScheduleService(repository: ScheduleRepository())
    }()

    lazy var planService: PlanService = {
        PlanService(planRepository: PlanRepository())
    }()

    lazy var placeService: PlaceService = {
        PlaceService(placeProtocol: PlaceRepository())
    }()

    lazy var bookMarkService: BookMarkService = {
        BookMarkService(bookMarkProtocol: BookMarkRepository())
    }()

    lazy var reviewService: ReviewService = {
        ReviewService(reviewProtocol: ReviewRepository())
    }()

    lazy var starService: StarService = {
        StarService(starProtocol: StarRepository())
    }()

    lazy var userService: UserService = {
        UserService(repository: UserRepository())
    }()

    lazy var guideService: GuideService = {
        GuideService(guideProtocol: GuideRepository())
    }()

    lazy var chatService: ChatService = {
        ChatService(chatProtocol: AIChatRepository())
    }()

    // MARK: - Singleton
    static let shared = ServiceContainer()
    private init() {}
}

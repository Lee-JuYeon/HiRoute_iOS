//
//  Untitled.swift
//  HiRoute
//
//  Created by Jupond on 11/26/25.
//

import Foundation
import UIKit

class ServiceContainer {
    
    // MARK: - Lazy Services (메모리 효율성)
    lazy var scheduleService: ScheduleService = {
        let service = ScheduleService(repository: ScheduleRepository())
        return service
    }()
    
    lazy var planService : PlanService = {
        let service = PlanService(planRepository: PlanRepository())
        return service
    }()
    
    lazy var placeService: PlaceService = {
        let service = PlaceService(placeProtocol: PlaceRepository())
        return service
    }()
    
    lazy var bookMarkService: BookMarkService = {
        let service = BookMarkService(bookMarkProtocol: BookMarkRepository())
        return service
    }()
    
    lazy var reviewService: ReviewService = {
        let service = ReviewService(reviewProtocol: ReviewRepository())
        return service
    }()
    
    lazy var starService: StarService = {
        let service = StarService(starProtocol: StarRepository())
        return service
    }()
    
    // MARK: - Singleton with Memory Management
    static let shared = ServiceContainer()
    
    private init() {
        setupMemoryPressureHandling()
    }
    
    // MARK: - Memory Pressure Handling
    
    /// 메모리 압박 상황 대응
    private func setupMemoryPressureHandling() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleMemoryPressure()
        }
        
        // 백그라운드 진입시에도 메모리 정리
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleBackgroundMemoryOptimization()
        }
    }
    
    /// 메모리 압박시 Repository 캐시 정리
    private func handleMemoryPressure() {
        print("🧹 Memory pressure detected - Clearing caches")
        
//        // 모든 Repository 캐시 정리
//        scheduleService.clearCache()
//        PlaceRepository.shared.clearCache()
//        BookMarkRepository.shared.clearCache()
//        ReviewRepository.shared.clearCache()
//        StarRepository.shared.clearCache()
    }
    
    /// 백그라운드 진입시 메모리 최적화
    private func handleBackgroundMemoryOptimization() {
        print("🧹 Background optimization - Partial cache cleanup")
        
//        // 부분적 캐시 정리 (LRU 기반)
//        ScheduleRepository.shared.optimizeCache()
//        PlaceRepository.shared.optimizeCache()
//        BookMarkRepository.shared.optimizeCache()
//        ReviewRepository.shared.optimizeCache()
//        StarRepository.shared.optimizeCache()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("✅ ServiceContainer deinit")
    }
}

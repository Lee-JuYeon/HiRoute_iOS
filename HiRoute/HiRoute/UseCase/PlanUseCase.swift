//
//  PlanUseCase.swift
//  HiRoute
//
//  Created by Jupond on 7/26/25.
//
import Combine
import Foundation

//class PlanUseCase {
//    private let repository: PlanRepositoryProtocol
//    
//    init(repository: PlanRepositoryProtocol) {
//        self.repository = repository
//    }
//    
//    func getAllPlans(page: Int = 1, itemsPerPage: Int = 10) -> AnyPublisher<[PlanModel], Error> {
//        return repository.fetchPlans(page: page, itemsPerPage: itemsPerPage)
//    }
//    
//    func createNewPlan(_ plan: PlanModel) -> AnyPublisher<PlanModel, Error> {
//        return repository.createPlan(plan)
//    }
//    
//    func updateExistingPlan(_ plan: PlanModel) -> AnyPublisher<PlanModel, Error> {
//        return repository.updatePlan(plan)
//    }
//    
//    func removePlan(planUID: String) -> AnyPublisher<Void, Error> {
//        return repository.deletePlan(planUID: planUID)
//    }
//    
//    func getPlanDetail(planUID: String) -> AnyPublisher<PlanModel, Error> {
//        return repository.fetchPlanDetail(planUID: planUID)
//    }
//    
//    func getPlansForToday() -> AnyPublisher<[PlanModel], Error> {
//        return getAllPlans()
//            .map { plans in
//                plans.filter { Calendar.current.isDateInToday($0.meetingDate) }
//            }
//            .eraseToAnyPublisher()
//    }
//    
//    func getPlansByActivityType(_ activityType: ActivityType) -> AnyPublisher<[PlanModel], Error> {
//        return getAllPlans()
//            .map { plans in
//                plans.filter { $0.activityType == activityType }
//            }
//            .eraseToAnyPublisher()
//    }
//}

//
//  PlanrepositoryProtocol.swift
//  HiRoute
//
//  Created by Jupond on 7/26/25.
//
import Foundation
import Combine

//class PlanRepository : PlanRepositoryProtocol {
//    
//    private let userDefaults = UserDefaults.standard
//    private let plansKey = "cached_plans"
//    
//    func fetchPlans(page: Int, itemsPerPage: Int) -> AnyPublisher<[PlanModel], Error> {
//        return Future { promise in
//            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
//                let mockPlans = DummyPack.sam
//                promise(.success(mockPlans))
//            }
//        }
//        .eraseToAnyPublisher()
//    }
//    
//    func createPlan(_ plan: PlanModel) -> AnyPublisher<PlanModel, Error> {
//        return Future { promise in
//            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
//                promise(.success(plan))
//            }
//        }
//        .eraseToAnyPublisher()
//    }
//    
//    func updatePlan(_ plan: PlanModel) -> AnyPublisher<PlanModel, Error> {
//        return Future { promise in
//            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
//                promise(.success(plan))
//            }
//        }
//        .eraseToAnyPublisher()
//    }
//    
//    func deletePlan(planUID: String) -> AnyPublisher<Void, Error> {
//        return Future { promise in
//            DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
//                promise(.success(()))
//            }
//        }
//        .eraseToAnyPublisher()
//    }
//    
//    func fetchPlanDetail(planUID: String) -> AnyPublisher<PlanModel, Error> {
//        return Future { promise in
//            DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
//                if let plan =  DummyPack.shared.samplePlans.first {
//                    promise(.success(plan))
//                } else {
//                    promise(.failure(NetworkError.noData))
//                }
//            }
//        }
//        .eraseToAnyPublisher()
//    }
//    
//    
//}

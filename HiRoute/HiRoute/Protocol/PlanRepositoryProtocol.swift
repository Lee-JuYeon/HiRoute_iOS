//
//  FeedRepositoryProtocol.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//

import Foundation
import Combine

protocol PlanRepositoryProtocol {
    func fetchPlans(page : Int, itemsPerPage : Int) -> AnyPublisher<[PlanModel], Error>
    func createPlan(_ plan: PlanModel) -> AnyPublisher<PlanModel, Error>
    func updatePlan(_ plan: PlanModel) -> AnyPublisher<PlanModel, Error>
    func deletePlan(planUID: String) -> AnyPublisher<Void, Error>
    func fetchPlanDetail(planUID: String) -> AnyPublisher<PlanModel, Error>
}

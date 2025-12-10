//
//  RouteRepositoryProtocol.swift
//  HiRoute
//
//  Created by Jupond on 7/26/25.
//

import Combine

protocol ScheduleProtocol {
    func create(_ scheduleModel: ScheduleModel) -> AnyPublisher<ScheduleModel, Error>
    func read(scheduleUID: String) -> AnyPublisher<ScheduleModel, Error>
    func readList(page: Int, itemsPerPage: Int) -> AnyPublisher<[ScheduleModel], Error>
    func update(_ scheduleModel: ScheduleModel) -> AnyPublisher<ScheduleModel, Error>
    func delete(scheduleUID: String) -> AnyPublisher<Void, Error>
}

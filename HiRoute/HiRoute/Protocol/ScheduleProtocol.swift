//
//  RouteRepositoryProtocol.swift
//  HiRoute
//
//  Created by Jupond on 7/26/25.
//

import Combine

protocol ScheduleProtocol {
    func createSchedule(_ scheduleModel: ScheduleModel) -> AnyPublisher<ScheduleModel, Error>
    func readSchedule(scheduleModelUID: String) -> AnyPublisher<ScheduleModel, Error>
    func readScheduleList(page: Int, itemsPerPage: Int) -> AnyPublisher<[ScheduleModel], Error>
    func updateSchedule(_ scheduleModel: ScheduleModel) -> AnyPublisher<ScheduleModel, Error>
    func deleteSchedule(scheduleModelUID: String) -> AnyPublisher<Void, Error>
}

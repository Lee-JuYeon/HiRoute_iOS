//
//  RouteRepositoryProtocol.swift
//  HiRoute
//
//  Created by Jupond on 7/26/25.
//

import Combine
import Foundation

protocol ScheduleProtocol {
    func create(_ scheduleModel: ScheduleModel) -> AnyPublisher<ScheduleModel, Error>
    func read(scheduleUID: String) -> AnyPublisher<ScheduleModel, Error>
    func readAll(page: Int, itemsPerPage: Int) -> AnyPublisher<[ScheduleModel], Error>
    func update(_ scheduleModel: ScheduleModel) -> AnyPublisher<ScheduleModel, Error>
    /// [2026-05-26 Phase 2] 메타 필드만 업데이트 — chatHistory/planList 안 건드림.
    func updateMeta(scheduleUID: String, title: String, memo: String, dDay: Date, editDate: Date) -> AnyPublisher<ScheduleModel, Error>
    func delete(scheduleUID: String) -> AnyPublisher<Void, Error>
    func reorderSchedules(scheduleUIDs: [String]) -> AnyPublisher<[ScheduleModel], Error>
    func appendChatMessage(scheduleUID: String, message: ChatMessageModel) -> AnyPublisher<Void, Error>
}

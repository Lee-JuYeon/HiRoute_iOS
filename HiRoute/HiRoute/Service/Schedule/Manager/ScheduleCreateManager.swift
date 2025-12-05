//
//  ScheduleCreateManager.swift
//  HiRoute
//
//  Created by Jupond on 12/5/25.
//

import Combine

class ScheduleCreateManager {
    private let scheduleProtocol: ScheduleProtocol
    private let networkMonitor: NetworkMonitor
    private weak var offlineQueueDelegate: OfflineQueueDelegate?
    
    init(
        scheduleProtocol: ScheduleProtocol,
        networkMonitor: NetworkMonitor,
         offlineQueueDelegate: OfflineQueueDelegate?
    ) {
        self.scheduleProtocol = scheduleProtocol
        self.networkMonitor = networkMonitor
        self.offlineQueueDelegate = offlineQueueDelegate
    }
    
    func create(_ schedule: ScheduleModel) -> AnyPublisher<ScheduleModel, Error> {
        let (networkStatus, _) = networkMonitor.getCurrentStatus()
        
        switch networkStatus {
        case .connected:
            return syncToServer(schedule)
        case .offline, .connecting:
            // 오프라인 큐에 추가
            offlineQueueDelegate?.addToQueue(.create(schedule))
            return Just(schedule)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    private func syncToServer(_ schedule: ScheduleModel) -> AnyPublisher<ScheduleModel, Error> {
        return repository.createSchedule(schedule)
    }
}

// MARK: - ScheduleUpdateManager
class ScheduleUpdateManager {
    private let scheduleProtocol: ScheduleProtocol
    private let networkMonitor: NetworkMonitor
    private weak var offlineQueueDelegate: OfflineQueueDelegate?
    
    init(
        scheduleProtocol: ScheduleProtocol,
        networkMonitor: NetworkMonitor,
         offlineQueueDelegate: OfflineQueueDelegate?
    ) {
        self.scheduleProtocol = scheduleProtocol
        self.networkMonitor = networkMonitor
        self.offlineQueueDelegate = offlineQueueDelegate
    }
    
    func update(_ schedule: ScheduleModel) -> AnyPublisher<ScheduleModel, Error> {
        let (networkStatus, _) = networkMonitor.getCurrentStatus()
        
        switch networkStatus {
        case .connected:
            return syncToServer(schedule)
        case .offline, .connecting:
            offlineQueueDelegate?.addToQueue(.update(schedule))
            return Just(schedule)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    func updateMemo(_ memo: String, for schedule: ScheduleModel) -> AnyPublisher<ScheduleModel, Error> {
        let updatedSchedule = schedule.updateModel(ScheduleModel(
            uid: schedule.uid,
            index: schedule.index,
            title: schedule.title,
            memo: memo,
            editDate: Date(),
            d_day: schedule.d_day,
            visitPlaceList: schedule.visitPlaceList
        ))
        
        return update(updatedSchedule)
    }
    
    func addPlace(_ place: PlaceModel, to schedule: ScheduleModel) throws -> ScheduleModel {
        // 비즈니스 규칙 검증
        guard schedule.visitPlaceList.count < 20 else {
            throw ScheduleError.maxPlacesReached
        }
        
        guard !schedule.visitPlaceList.contains(where: { $0.placeModel.uid == place.uid }) else {
            throw ScheduleError.duplicatePlace
        }
        
        let newVisitPlace = VisitPlaceModel(
            uid: UUID().uuidString,
            index: schedule.visitPlaceList.count,
            memo: "",
            placeModel: place,
            files: []
        )
        
        var updatedVisitPlaces = schedule.visitPlaceList
        updatedVisitPlaces.append(newVisitPlace)
        
        return schedule.updateModel(ScheduleModel(
            uid: schedule.uid,
            index: schedule.index,
            title: schedule.title,
            memo: schedule.memo,
            editDate: Date(),
            d_day: schedule.d_day,
            visitPlaceList: updatedVisitPlaces
        ))
    }
    
    private func syncToServer(_ schedule: ScheduleModel) -> AnyPublisher<ScheduleModel, Error> {
        return repository.updateSchedule(schedule)
    }
}

// MARK: - ScheduleReadManager
class ScheduleReadManager {
    private let scheduleProtocol: ScheduleProtocol
    private let networkMonitor: NetworkMonitor
    
    init(
        scheduleProtocol: ScheduleProtocol,
        networkMonitor: NetworkMonitor,
    ) {
        self.scheduleProtocol = scheduleProtocol
        self.networkMonitor = networkMonitor
    }
    
    func load(uid: String) -> AnyPublisher<ScheduleModel, Error> {
        return repository.readSchedule(scheduleModelUID: uid)
    }
    
    func loadList(page: Int = 0, itemsPerPage: Int = 20) -> AnyPublisher<[ScheduleModel], Error> {
        return repository.readScheduleList(page: page, itemsPerPage: itemsPerPage)
    }
    
    func searchSchedules(_ schedules: [ScheduleModel], by title: String) -> [ScheduleModel] {
        return schedules.filter { $0.title.lowercased().contains(title.lowercased()) }
    }
    
    func getUpcomingSchedules(_ schedules: [ScheduleModel]) -> [ScheduleModel] {
        return schedules.filter { $0.d_day > Date() }
            .sorted { $0.d_day < $1.d_day }
    }
}

// MARK: - ScheduleDeleteManager
class ScheduleDeleteManager {
    private let scheduleProtocol: ScheduleProtocol
    private let networkMonitor: NetworkMonitor
    private weak var offlineQueueDelegate: OfflineQueueDelegate?
    
    init(
        scheduleProtocol: ScheduleProtocol,
        networkMonitor: NetworkMonitor,
         offlineQueueDelegate: OfflineQueueDelegate?
    ) {
        self.scheduleProtocol = scheduleProtocol
        self.networkMonitor = networkMonitor
        self.offlineQueueDelegate = offlineQueueDelegate
    }
    
    func delete(uid: String) -> AnyPublisher<Void, Error> {
        let (networkStatus, _) = networkMonitor.getCurrentStatus()
        
        switch networkStatus {
        case .connected:
            return syncToServer(uid: uid)
        case .offline, .connecting:
            offlineQueueDelegate?.addToQueue(.delete(uid))
            return Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    private func syncToServer(uid: String) -> AnyPublisher<Void, Error> {
        return repository.deleteSchedule(scheduleModelUID: uid)
    }
}

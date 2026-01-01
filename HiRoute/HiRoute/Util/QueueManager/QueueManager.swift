//
//  QueueManager.swift
//  HiRoute
//
//  Created by Jupond on 12/5/25.
//

import Foundation
import Combine

class QueueManager: ObservableObject {
    
    static let shared = QueueManager()
    private var operationQueue: [QueueOperation] = []
    
    private init() {
        print("QueueManager, init // Success : 오프라인 CRUD 큐 매니저 초기화")
    }
    
    // MARK: - Enqueue Operations
    
    func enqueueCreate(schedule: ScheduleModel) throws {
        operationQueue.append(.create(schedule))
        print("QueueManager, enqueueCreate // Info : 생성 작업 큐에 추가 - \(schedule.title)")
    }
    
    func enqueueUpdate(schedule: ScheduleModel) throws {
        operationQueue.append(.update(schedule))
        print("QueueManager, enqueueUpdate // Info : 수정 작업 큐에 추가 - \(schedule.title)")
    }
    
    func enqueueDelete(scheduleUID: String) throws {
        operationQueue.append(.delete(scheduleUID))
        print("QueueManager, enqueueDelete // Info : 삭제 작업 큐에 추가 - \(scheduleUID)")
    }
    
    func enqueueReadAll() throws {
        operationQueue.append(.readAll)
        print("QueueManager, enqueueReadAll // Info : 전체 조회 작업 큐에 추가")
    }

    func enqueueRead(scheduleUID: String) throws {
        operationQueue.append(.read(scheduleUID))
        print("QueueManager, enqueueRead // Info : 단일 조회 작업 큐에 추가 - \(scheduleUID)")
    }
    
    // MARK: - Process Queue
    
    func processQueue() -> AnyPublisher<[QueueResult], Never> {
        let operationsToProcess = operationQueue
        operationQueue.removeAll()
        
        print("QueueManager, processQueue // Info : \(operationsToProcess.count)개 작업 처리 시작")
        
        let results = operationsToProcess.map { operation in
            QueueResult(operation: operation, status: QueueStatus.pending)
        }
        
        return Just(results).eraseToAnyPublisher()
    }
    
    // MARK: - Queue Status
    
    var queueCount: Int {
        return operationQueue.count
    }
    
    var hasQueuedOperations: Bool {
        return !operationQueue.isEmpty
    }
    
    func getQueueSummary() -> QueueSummary {
        let createCount = operationQueue.filter { if case .create = $0 { return true }; return false }.count
        let updateCount = operationQueue.filter { if case .update = $0 { return true }; return false }.count
        let deleteCount = operationQueue.filter { if case .delete = $0 { return true }; return false }.count
        let readCount = operationQueue.filter {
            if case .readAll = $0 { return true }
            if case .read = $0 { return true }
            return false
        }.count
        
        return QueueSummary(
            create: createCount,
            update: updateCount,
            delete: deleteCount,
            read: readCount,    // sync → read로 변경
            total: operationQueue.count
        )
    }
}

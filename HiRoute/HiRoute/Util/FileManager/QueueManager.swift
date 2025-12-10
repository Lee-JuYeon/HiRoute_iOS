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
    
    private var queues: [String: Queue] = [:]
    private let queueAccessQueue = DispatchQueue(label: "QueueManager.access", attributes: .concurrent)
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Queue Configuration
    struct QueueConfig {
        let maxRetries: Int
        let retryDelay: TimeInterval
        let maxConcurrentOperations: Int
        let enablePersistence: Bool // CoreData 저장 여부
        
        static let `default` = QueueConfig(
            maxRetries: 3,
            retryDelay: 2.0,
            maxConcurrentOperations: 3,
            enablePersistence: true
        )
        
        static let lowPriority = QueueConfig(
            maxRetries: 1,
            retryDelay: 5.0,
            maxConcurrentOperations: 1,
            enablePersistence: false
        )
    }
    
    // MARK: - Operation Types
    enum OperationType: String, CaseIterable {
        // Schedule operations
        case createSchedule = "schedule.create"
        case updateSchedule = "schedule.update"
        case deleteSchedule = "schedule.delete"
        
        // Place operations
        case createPlace = "place.create"
        case updatePlace = "place.update"
        case deletePlace = "place.delete"
        
        // Review operations
        case createReview = "review.create"
        case updateReview = "review.update"
        
        // File upload operations
        case uploadImage = "file.upload"
        case syncBookmarks = "bookmark.sync"
    }
    
    enum Priority: Int, CaseIterable, Comparable {
        case critical = 0   // 즉시 처리
        case high = 1      // 우선 처리
        case normal = 2    // 일반 처리
        case low = 3       // 나중에 처리
        
        static func < (lhs: Priority, rhs: Priority) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
    
    // MARK: - Queue Operation
    struct QueueOperation {
        let id: UUID
        let type: OperationType
        let priority: Priority
        let data: Data
        let createdAt: Date
        var retryCount: Int
        var scheduledAt: Date?
        
        init<T: Codable>(type: OperationType, priority: Priority = .normal, payload: T) throws {
            self.id = UUID()
            self.type = type
            self.priority = priority
            self.data = try JSONEncoder().encode(payload)
            self.createdAt = Date()
            self.retryCount = 0
        }
    }
    
    // MARK: - Queue Implementation
    private class Queue {
        let name: String
        let config: QueueConfig
        private var operations: [QueueOperation] = []
        private let accessQueue = DispatchQueue(label: "Queue.\(UUID())", attributes: .concurrent)
        private var isProcessing = false
        
        var operationHandler: ((QueueOperation) async throws -> Void)?
        var onOperationComplete: ((QueueOperation, Bool) -> Void)?
        
        init(name: String, config: QueueConfig) {
            self.name = name
            self.config = config
        }
        
        func enqueue(_ operation: QueueOperation) {
            accessQueue.async(flags: .barrier) {
                // 우선순위에 따라 정렬하여 삽입
                if let index = self.operations.firstIndex(where: { $0.priority > operation.priority }) {
                    self.operations.insert(operation, at: index)
                } else {
                    self.operations.append(operation)
                }
                
                print("📥 [\(self.name)] 큐에 추가: \(operation.type.rawValue), 우선순위: \(operation.priority)")
            }
            
            processIfNeeded()
        }
        
        func processIfNeeded() {
            accessQueue.async(flags: .barrier) {
                guard !self.isProcessing && !self.operations.isEmpty else { return }
                self.isProcessing = true
                
                Task {
                    await self.processNextOperation()
                }
            }
        }
        
        private func processNextOperation() async {
            while true {
                let operation = accessQueue.sync { () -> QueueOperation? in
                    guard !operations.isEmpty else { return nil }
                    return operations.removeFirst()
                }
                
                guard let op = operation else {
                    accessQueue.async(flags: .barrier) {
                        self.isProcessing = false
                    }
                    break
                }
                
                await executeOperation(op)
            }
        }
        
        private func executeOperation(_ operation: QueueOperation) async {
            do {
                try await operationHandler?(operation)
                onOperationComplete?(operation, true)
                print("✅ [\(name)] 완료: \(operation.type.rawValue)")
                
            } catch {
                print("❌ [\(name)] 실패: \(operation.type.rawValue), 에러: \(error)")
                
                if operation.retryCount < config.maxRetries {
                    var retryOp = operation
                    retryOp.retryCount += 1
                    retryOp.scheduledAt = Date().addingTimeInterval(config.retryDelay * Double(retryOp.retryCount))
                    
                    // 재시도는 지연 후 다시 큐에 추가
                    DispatchQueue.global().asyncAfter(deadline: .now() + config.retryDelay) {
                        self.enqueue(retryOp)
                    }
                } else {
                    onOperationComplete?(operation, false)
                    print("💀 [\(name)] 최종 실패: \(operation.type.rawValue)")
                }
            }
        }
        
        var count: Int {
            accessQueue.sync { operations.count }
        }
        
        func clear() {
            accessQueue.async(flags: .barrier) {
                self.operations.removeAll()
                self.isProcessing = false
            }
        }
    }
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// 큐 생성 또는 가져오기
    func getQueue(name: String, config: QueueConfig = .default) -> String {
        return queueAccessQueue.sync(flags: .barrier) {
            if queues[name] == nil {
                let queue = Queue(name: name, config: config)
                queues[name] = queue
                print("🏗️ 큐 생성: \(name)")
            }
            return name
        }
    }
    
    /// 작업을 큐에 추가
    func enqueue<T: Codable>(
        queueName: String,
        type: OperationType,
        payload: T,
        priority: Priority = .normal
    ) throws {
        let operation = try QueueOperation(type: type, priority: priority, payload: payload)
        
        queueAccessQueue.sync {
            queues[queueName]?.enqueue(operation)
        }
    }
    
    /// 큐의 작업 처리기 등록
    func setOperationHandler(
        for queueName: String,
        handler: @escaping (QueueOperation) async throws -> Void
    ) {
        queueAccessQueue.sync {
            queues[queueName]?.operationHandler = handler
        }
    }
    
    /// 완료 콜백 등록
    func setCompletionHandler(
        for queueName: String,
        handler: @escaping (QueueOperation, Bool) -> Void
    ) {
        queueAccessQueue.sync {
            queues[queueName]?.onOperationComplete = handler
        }
    }
    
    /// 큐 시작 (수동 제어용)
    func startQueue(_ queueName: String) {
        queueAccessQueue.sync {
            queues[queueName]?.processIfNeeded()
        }
    }
    
    /// 큐 정리
    func clearQueue(_ queueName: String) {
        queueAccessQueue.sync {
            queues[queueName]?.clear()
        }
    }
    
    /// 모든 큐 정리
    func clearAllQueues() {
        queueAccessQueue.sync(flags: .barrier) {
            queues.values.forEach { $0.clear() }
            print("🧹 모든 큐 정리 완료")
        }
    }
    
    /// 큐 상태 조회
    func getQueueStatus() -> [String: Int] {
        return queueAccessQueue.sync {
            queues.mapValues { $0.count }
        }
    }
    
    /// 특정 큐의 작업 수
    func getQueueCount(_ queueName: String) -> Int {
        return queueAccessQueue.sync {
            queues[queueName]?.count ?? 0
        }
    }
    
    deinit {
        cancellables.removeAll()
        clearAllQueues()
        print("✅ QueueManager deinit")
    }
}

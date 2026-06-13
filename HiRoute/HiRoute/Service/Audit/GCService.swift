//
//  GCService.swift
//  HiRoute
//
//  Created by Claude on 5/26/26.
//
//  [2026-05-26 Phase 3] soft-deleted row의 hard delete 가비지 컬렉터.
//  Why: 7일 grace period가 끝난 데이터를 실제 정리. 디스크 무한 증식 방지.
//  When: 앱 시작 시 1회. 너무 자주 돌리면 사용자에게 인지 시간 안 줌.
//

import Foundation
import CoreData

final class GCService {
    static let shared = GCService()

    private let queue = DispatchQueue(label: "com.nunulala.gc", qos: .background)
    /// soft delete 후 hard delete까지 grace period.
    /// Phase 3 권고: 7일. 사용자 인지 + 복구 가능성 확보.
    private let gracePeriod: TimeInterval = 7 * 24 * 60 * 60
    private let lastRunKey = "GCService.lastRunAt"
    /// 최소 실행 간격 — 같은 세션에서 여러 번 호출돼도 1일에 1회만.
    private let minInterval: TimeInterval = 24 * 60 * 60

    private init() {}

    /// 앱 시작 시 호출. 너무 자주 안 돌도록 내부에서 throttling.
    func runIfDue() {
        let lastRun = (UserDefaults.standard.object(forKey: lastRunKey) as? Date) ?? .distantPast
        guard Date().timeIntervalSince(lastRun) >= minInterval else {
            print("GCService, runIfDue // skip — 마지막 실행이 \(Int(Date().timeIntervalSince(lastRun)))초 전")
            return
        }
        run()
    }

    /// 강제 실행 (테스트/디버그용).
    func run() {
        queue.async { [weak self] in
            self?.collect()
            UserDefaults.standard.set(Date(), forKey: self?.lastRunKey ?? "")
        }
    }

    // MARK: - Internals

    private func collect() {
        let context = CoreDataStack.shared.persistentContainer.newBackgroundContext()
        let threshold = Date().addingTimeInterval(-gracePeriod)
        var totalDeleted = 0

        context.performAndWait {
            totalDeleted += hardDelete(entityName: "ScheduleChatEntity", threshold: threshold, context: context)
            totalDeleted += hardDelete(entityName: "FileEntity", threshold: threshold, context: context)
            totalDeleted += hardDelete(entityName: "PlanEntity", threshold: threshold, context: context)
            totalDeleted += hardDelete(entityName: "ScheduleEntity", threshold: threshold, context: context)
            do {
                try context.save()
                print("GCService, collect // Success : 총 \(totalDeleted)개 hard delete (>\(Int(gracePeriod / 86400))일 경과)")
            } catch {
                print("GCService, collect // Exception : \(error.localizedDescription)")
            }
        }
    }

    private func hardDelete(entityName: String, threshold: Date, context: NSManagedObjectContext) -> Int {
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        request.predicate = NSPredicate(format: "deletedAt != nil AND deletedAt < %@", threshold as NSDate)
        do {
            let stale = try context.fetch(request)
            stale.forEach { context.delete($0) }
            if !stale.isEmpty {
                print("GCService, hardDelete // \(entityName) \(stale.count)개")
            }
            return stale.count
        } catch {
            print("GCService, hardDelete // Exception (\(entityName)) : \(error.localizedDescription)")
            return 0
        }
    }
}

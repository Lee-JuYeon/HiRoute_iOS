//
//  Untitled.swift
//  HiRoute
//
//  Created by Jupond on 12/5/25.
//
import CoreData

class LocalDB {
    static let shared = LocalDB()
    private let backgroundContext: NSManagedObjectContext
    
    private init() {
        backgroundContext = CoreDataStack.shared.persistentContainer.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
        backgroundContext.undoManager = nil
        backgroundContext.shouldDeleteInaccessibleFaults = true
        print("LocalDB, init // Success : 백그라운드 컨텍스트 초기화 완료")
    }
        
    /// 일정 생성
    func createSchedule(_ schedule: ScheduleModel, completion: @escaping (Bool) -> Void) {
        print("LocalDB, createSchedule // Info : 일정 생성 시작 - \(schedule.uid)")
        ScheduleDAO.create(schedule, context: backgroundContext, completion: completion)
    }
    
    /// 일정 조회
    func readSchedule(scheduleUID: String, completion: @escaping (ScheduleModel?) -> Void) {
        print("LocalDB, readSchedule // Info : 일정 조회 시작 - \(scheduleUID)")
        ScheduleDAO.read(scheduleUID: scheduleUID, context: backgroundContext, completion: completion)
    }
    
    /// 모든 일정 조회
    func readAllSchedules(completion: @escaping ([ScheduleModel]) -> Void) {
        print("LocalDB, readAllSchedules // Info : 모든 일정 조회 시작")
        ScheduleDAO.readAll(context: backgroundContext, completion: completion)
    }
    
    /// 일정 업데이트
    func updateSchedule(_ schedule: ScheduleModel, completion: @escaping (Bool) -> Void) {
        print("LocalDB, updateSchedule // Info : 일정 업데이트 시작 - \(schedule.uid)")
        ScheduleDAO.update(schedule, context: backgroundContext, completion: completion)
    }
    
    /// 일정 삭제
    func deleteSchedule(scheduleUID: String, completion: @escaping (Bool) -> Void) {
        print("LocalDB, deleteSchedule // Info : 일정 삭제 시작 - \(scheduleUID)")
        ScheduleDAO.delete(scheduleUID: scheduleUID, context: backgroundContext, completion: completion)
    }
    
    
    /// Plan 생성
    func createPlan(_ plan: PlanModel, scheduleUID: String, completion: @escaping (Bool) -> Void) {
        print("LocalDB, createPlan // Info : Plan 생성 시작 - \(plan.uid)")
        PlanDAO.create(plan, scheduleUID: scheduleUID, context: backgroundContext, completion: completion)
    }
    
    /// Plan 조회
    func readPlan(planUID: String, completion: @escaping (PlanModel?) -> Void) {
        print("LocalDB, readPlan // Info : Plan 조회 시작 - \(planUID)")
        PlanDAO.read(planUID: planUID, context: backgroundContext, completion: completion)
    }
    
    /// Plan 목록 조회
    func readPlanList(scheduleUID: String, completion: @escaping ([PlanModel]) -> Void) {
        print("LocalDB, readPlanList // Info : Plan 목록 조회 시작 - \(scheduleUID)")
        PlanDAO.readAll(scheduleUID: scheduleUID, context: backgroundContext, completion: completion)
    }
    
    /// Plan 업데이트
    func updatePlan(_ plan: PlanModel, completion: @escaping (Bool) -> Void) {
        print("LocalDB, updatePlan // Info : Plan 업데이트 시작 - \(plan.uid)")
        PlanDAO.update(plan, context: backgroundContext, completion: completion)
    }
    
    /// Plan 메모 업데이트
    func updatePlanMemo(planUID: String, memo: String, completion: @escaping (Bool) -> Void) {
        print("LocalDB, updatePlanMemo // Info : Plan 메모 업데이트 시작 - \(planUID)")
        PlanDAO.updateMemo(planUID: planUID, memo: memo, context: backgroundContext, completion: completion)
    }
    
    /// Plan 인덱스 업데이트
    func updatePlanIndex(planUID: String, newIndex: Int, completion: @escaping (Bool) -> Void) {
        print("LocalDB, updatePlanIndex // Info : Plan 인덱스 업데이트 시작 - \(planUID)")
        PlanDAO.updateIndex(planUID: planUID, newIndex: newIndex, context: backgroundContext, completion: completion)
    }
    
    /// Plan 삭제
    func deletePlan(planUID: String, completion: @escaping (Bool) -> Void) {
        print("LocalDB, deletePlan // Info : Plan 삭제 시작 - \(planUID)")
        PlanDAO.delete(planUID: planUID, context: backgroundContext, completion: completion)
    }
}

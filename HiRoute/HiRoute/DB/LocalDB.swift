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
    
    // MARK: - Schedule CRUD
    
    /// 일정 생성
    func createSchedule(_ schedule: ScheduleModel) -> Bool {
        print("LocalDB, createSchedule // Info : 일정 생성 시작 - \(schedule.uid)")
        return ScheduleDAO.create(schedule, context: backgroundContext)
    }
    
    /// 일정 조회
    func readSchedule(scheduleUID: String) -> ScheduleModel? {
        print("LocalDB, readSchedule // Info : 일정 조회 시작 - \(scheduleUID)")
        return ScheduleDAO.read(scheduleUID: scheduleUID, context: backgroundContext)
    }
    
    /// 모든 일정 조회
    func readAllSchedules() -> [ScheduleModel] {
        print("LocalDB, readAllSchedules // Info : 모든 일정 조회 시작")
        return ScheduleDAO.readAll(context: backgroundContext)
    }
    
    /// 일정 업데이트
    func updateSchedule(_ schedule: ScheduleModel) -> Bool {
        print("LocalDB, updateSchedule // Info : 일정 업데이트 시작 - \(schedule.uid)")
        return ScheduleDAO.update(schedule, context: backgroundContext)
    }
    
    /// 일정 삭제
    func deleteSchedule(scheduleUID: String) -> Bool {
        print("LocalDB, deleteSchedule // Info : 일정 삭제 시작 - \(scheduleUID)")
        return ScheduleDAO.delete(scheduleUID: scheduleUID, context: backgroundContext)
    }
    
    // MARK: - Plan CRUD
    
    /// Plan 생성
    func createPlan(_ plan: PlanModel, scheduleUID: String) -> Bool {
        print("LocalDB, createPlan // Info : Plan 생성 시작 - \(plan.uid)")
        return PlanDAO.create(plan, scheduleUID: scheduleUID, context: backgroundContext)
    }
    
    /// Plan 조회
    func readPlan(planUID: String) -> PlanModel? {
        print("LocalDB, readPlan // Info : Plan 조회 시작 - \(planUID)")
        return PlanDAO.read(planUID: planUID, context: backgroundContext)
    }
    
    /// Plan 목록 조회
    func readPlanList(scheduleUID: String) -> [PlanModel] {
        print("LocalDB, readPlanList // Info : Plan 목록 조회 시작 - \(scheduleUID)")
        return PlanDAO.readAll(scheduleUID: scheduleUID, context: backgroundContext)
    }
    
    /// Plan 업데이트
    func updatePlan(_ plan: PlanModel) -> Bool {
        print("LocalDB, updatePlan // Info : Plan 업데이트 시작 - \(plan.uid)")
        return PlanDAO.update(plan, context: backgroundContext)
    }
    
    /// Plan 메모 업데이트
    func updatePlanMemo(planUID: String, memo: String) -> Bool {
        print("LocalDB, updatePlanMemo // Info : Plan 메모 업데이트 시작 - \(planUID)")
        return PlanDAO.updateMemo(planUID: planUID, memo: memo, context: backgroundContext)
    }
    
    /// Plan 인덱스 업데이트
    func updatePlanIndex(planUID: String, newIndex: Int) -> Bool {
        print("LocalDB, updatePlanIndex // Info : Plan 인덱스 업데이트 시작 - \(planUID)")
        return PlanDAO.updateIndex(planUID: planUID, newIndex: newIndex, context: backgroundContext)
    }
    
    /// Plan 삭제
    func deletePlan(planUID: String) -> Bool {
        print("LocalDB, deletePlan // Info : Plan 삭제 시작 - \(planUID)")
        return PlanDAO.delete(planUID: planUID, context: backgroundContext)
    }
}

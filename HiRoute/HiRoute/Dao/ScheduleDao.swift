//
//  ScheduleDB.swift
//  HiRoute
//
//  Created by Jupond on 12/29/25.
//

import CoreData

struct ScheduleDAO {
    private init() {}
    
    /// 스레드 안전성 검증
    private static func validateContextSafety(context: NSManagedObjectContext) -> Bool {
        if context.concurrencyType == .mainQueueConcurrencyType {
            return Thread.isMainThread
        }
        return true
    }
    
    /// iOS 8 호환 동기 실행 헬퍼
    private static func performSynchronously<T>(on context: NSManagedObjectContext, block: @escaping () -> T) -> T {
        var result: T?
        let semaphore = DispatchSemaphore(value: 0)
        
        context.perform {
            result = block()
            semaphore.signal()
        }
        
        semaphore.wait()
        return result!
    }
    
    /// Schedule 생성
    static func create(_ schedule: ScheduleModel, context: NSManagedObjectContext) -> Bool {
        guard validateContextSafety(context: context) else {
            print("ScheduleDAO, create // Exception : 잘못된 컨텍스트 스레드 사용")
            return false
        }
        
        return performSynchronously(on: context) {
            do {
                if read(scheduleUID: schedule.uid, context: context) != nil {
                    print("ScheduleDAO, create // Warning : 이미 존재하는 일정 - \(schedule.uid)")
                    return false
                }
                
                let scheduleEntity = ScheduleEntity(context: context)
                scheduleEntity.uid = schedule.uid
                scheduleEntity.index = Int32(schedule.index)
                scheduleEntity.title = schedule.title
                scheduleEntity.memo = schedule.memo
                scheduleEntity.editDate = schedule.editDate
                scheduleEntity.d_day = schedule.d_day
                
                // Plan들 저장
                for plan in schedule.planList {
                    let planEntity = createPlanEntity(from: plan, schedule: scheduleEntity, context: context)
                    scheduleEntity.addToPlanList(planEntity)
                }
                
                try context.save()
                print("ScheduleDAO, create // Success : 일정 저장 완료 - \(schedule.title)")
                return true
                
            } catch {
                print("ScheduleDAO, create // Exception : \(error.localizedDescription)")
                return false
            }
        }
    }
    
    /// Schedule 업데이트
    static func update(_ schedule: ScheduleModel, context: NSManagedObjectContext) -> Bool {
        guard validateContextSafety(context: context) else {
            print("ScheduleDAO, update // Exception : 잘못된 컨텍스트 스레드 사용")
            return false
        }
        
        return performSynchronously(on: context) {
            do {
                let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
                request.predicate = NSPredicate(format: "uid == %@", schedule.uid)
                
                if let existingEntity = try context.fetch(request).first {
                    // 기존 관계 데이터 삭제
                    if let plans = existingEntity.planList as? Set<PlanEntity> {
                        for plan in plans {
                            context.delete(plan)
                        }
                    }
                    
                    // 업데이트
                    existingEntity.title = schedule.title
                    existingEntity.memo = schedule.memo
                    existingEntity.editDate = schedule.editDate
                    existingEntity.d_day = schedule.d_day
                    existingEntity.index = Int32(schedule.index)
                    
                    // 새 Plan들 추가
                    for plan in schedule.planList {
                        let planEntity = createPlanEntity(from: plan, schedule: existingEntity, context: context)
                        existingEntity.addToPlanList(planEntity)
                    }
                    
                    try context.save()
                    print("ScheduleDAO, update // Success : 일정 업데이트 완료 - \(schedule.title)")
                    return true
                } else {
                    return create(schedule, context: context)
                }
            } catch {
                print("ScheduleDAO, update // Exception : \(error.localizedDescription)")
                return false
            }
        }
    }
    
    /// Schedule 삭제
    static func delete(scheduleUID: String, context: NSManagedObjectContext) -> Bool {
        guard validateContextSafety(context: context) else {
            print("ScheduleDAO, delete // Exception : 잘못된 컨텍스트 스레드 사용")
            return false
        }
        
        return performSynchronously(on: context) {
            do {
                let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
                request.predicate = NSPredicate(format: "uid == %@", scheduleUID)
                
                if let entity = try context.fetch(request).first {
                    context.delete(entity)
                    try context.save()
                    print("ScheduleDAO, delete // Success : 일정 삭제 완료 - \(scheduleUID)")
                    return true
                } else {
                    print("ScheduleDAO, delete // Warning : 일정을 찾을 수 없음 - \(scheduleUID)")
                    return false
                }
            } catch {
                print("ScheduleDAO, delete // Exception : \(error.localizedDescription)")
                return false
            }
        }
    }
    
    /// Schedule 조회
    static func read(scheduleUID: String, context: NSManagedObjectContext) -> ScheduleModel? {
        guard validateContextSafety(context: context) else {
            print("ScheduleDAO, read // Exception : 잘못된 컨텍스트 스레드 사용")
            return nil
        }
        
        return performSynchronously(on: context) {
            do {
                let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
                request.predicate = NSPredicate(format: "uid == %@", scheduleUID)
                
                if let entity = try context.fetch(request).first {
                    print("ScheduleDAO, read // Success : 일정 조회 완료 - \(scheduleUID)")
                    return convertToScheduleModel(entity)
                }
                return nil
            } catch {
                print("ScheduleDAO, read // Exception : \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    /// 모든 Schedule 조회
    static func readAll(context: NSManagedObjectContext) -> [ScheduleModel] {
        guard validateContextSafety(context: context) else {
            print("ScheduleDAO, readAll // Exception : 잘못된 컨텍스트 스레드 사용")
            return []
        }
        
        return performSynchronously(on: context) {
            do {
                let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(key: "editDate", ascending: false)]
                
                let entities = try context.fetch(request)
                print("ScheduleDAO, readAll // Success : 일정 목록 조회 완료 - \(entities.count)개")
                return entities.compactMap { convertToScheduleModel($0) }
            } catch {
                print("ScheduleDAO, readAll // Exception : \(error.localizedDescription)")
                return []
            }
        }
    }
    
    // MARK: - Private Helpers (기존과 동일)
    
    private static func createPlanEntity(from plan: PlanModel, schedule: ScheduleEntity, context: NSManagedObjectContext) -> PlanEntity {
        let entity = PlanEntity(context: context)
        entity.uid = plan.uid
        entity.index = Int32(plan.index)
        entity.memo = plan.memo
        entity.schedule = schedule
        return entity
    }
    
    private static func convertToScheduleModel(_ entity: ScheduleEntity) -> ScheduleModel? {
        guard let uid = entity.uid else { return nil }
        
        let plans = convertPlansToModels(entity.planList)
        
        return ScheduleModel(
            uid: uid,
            index: Int(entity.index),
            title: entity.title ?? "",
            memo: entity.memo ?? "",
            editDate: entity.editDate ?? Date(),
            d_day: entity.d_day ?? Date(),
            planList: plans
        )
    }
    
    private static func convertPlansToModels(_ planEntities: NSSet?) -> [PlanModel] {
        guard let planSet = planEntities as? Set<PlanEntity> else { return [] }
        
        let sortedPlans = planSet.sorted { $0.index < $1.index }
        return sortedPlans.compactMap { convertToPlanModel($0) }
    }
    
    private static func convertToPlanModel(_ entity: PlanEntity) -> PlanModel? {
        guard let uid = entity.uid else { return nil }
        
        return PlanModel(
            uid: uid,
            index: Int(entity.index),
            memo: entity.memo ?? "",
            placeModel: PlaceModel.empty(),
            files: []
        )
    }
}

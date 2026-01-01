//
//  PlanDB.swift
//  HiRoute
//
//  Created by Jupond on 12/29/25.
//
import CoreData

struct PlanDAO {
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
    
    /// Plan 생성
    static func create(_ plan: PlanModel, scheduleUID: String, context: NSManagedObjectContext) -> Bool {
        guard validateContextSafety(context: context) else {
            print("PlanDAO, create // Exception : 잘못된 컨텍스트 스레드 사용")
            return false
        }
        
        return performSynchronously(on: context) {
            do {
                let scheduleRequest: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
                scheduleRequest.predicate = NSPredicate(format: "uid == %@", scheduleUID)
                
                guard let scheduleEntity = try context.fetch(scheduleRequest).first else {
                    print("PlanDAO, create // Warning : Schedule을 찾을 수 없음 - \(scheduleUID)")
                    return false
                }
                
                if read(planUID: plan.uid, context: context) != nil {
                    print("PlanDAO, create // Warning : 이미 존재하는 Plan - \(plan.uid)")
                    return false
                }
                
                let planEntity = createPlanEntity(from: plan, schedule: scheduleEntity, context: context)
                scheduleEntity.addToPlanList(planEntity)
                
                try context.save()
                print("PlanDAO, create // Success : Plan 저장 완료 - \(plan.uid)")
                return true
                
            } catch {
                print("PlanDAO, create // Exception : \(error.localizedDescription)")
                return false
            }
        }
    }
    
    /// Plan 조회
    static func read(planUID: String, context: NSManagedObjectContext) -> PlanModel? {
        guard validateContextSafety(context: context) else {
            print("PlanDAO, read // Exception : 잘못된 컨텍스트 스레드 사용")
            return nil
        }
        
        return performSynchronously(on: context) {
            do {
                let request: NSFetchRequest<PlanEntity> = PlanEntity.fetchRequest()
                request.predicate = NSPredicate(format: "uid == %@", planUID)
                
                if let entity = try context.fetch(request).first {
                    print("PlanDAO, read // Success : Plan 조회 완료 - \(planUID)")
                    return convertToPlanModel(entity)
                }
                return nil
            } catch {
                print("PlanDAO, read // Exception : \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    /// Plan 목록 조회
    static func readAll(scheduleUID: String, context: NSManagedObjectContext) -> [PlanModel] {
        guard validateContextSafety(context: context) else {
            print("PlanDAO, readAll // Exception : 잘못된 컨텍스트 스레드 사용")
            return []
        }
        
        return performSynchronously(on: context) {
            do {
                let request: NSFetchRequest<PlanEntity> = PlanEntity.fetchRequest()
                request.predicate = NSPredicate(format: "schedule.uid == %@", scheduleUID)
                request.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
                
                let entities = try context.fetch(request)
                print("PlanDAO, readAll // Success : Plan 목록 조회 완료 - \(entities.count)개")
                return entities.compactMap { convertToPlanModel($0) }
            } catch {
                print("PlanDAO, readAll // Exception : \(error.localizedDescription)")
                return []
            }
        }
    }
    
    /// Plan 업데이트
    static func update(_ plan: PlanModel, context: NSManagedObjectContext) -> Bool {
        guard validateContextSafety(context: context) else {
            print("PlanDAO, update // Exception : 잘못된 컨텍스트 스레드 사용")
            return false
        }
        
        return performSynchronously(on: context) {
            do {
                let request: NSFetchRequest<PlanEntity> = PlanEntity.fetchRequest()
                request.predicate = NSPredicate(format: "uid == %@", plan.uid)
                
                if let existingEntity = try context.fetch(request).first {
                    existingEntity.index = Int32(plan.index)
                    existingEntity.memo = plan.memo
                    
                    try context.save()
                    print("PlanDAO, update // Success : Plan 업데이트 완료 - \(plan.uid)")
                    return true
                } else {
                    print("PlanDAO, update // Warning : Plan을 찾을 수 없음 - \(plan.uid)")
                    return false
                }
            } catch {
                print("PlanDAO, update // Exception : \(error.localizedDescription)")
                return false
            }
        }
    }
    
    /// Plan 메모만 업데이트
    static func updateMemo(planUID: String, memo: String, context: NSManagedObjectContext) -> Bool {
        guard validateContextSafety(context: context) else {
            print("PlanDAO, updateMemo // Exception : 잘못된 컨텍스트 스레드 사용")
            return false
        }
        
        return performSynchronously(on: context) {
            do {
                let request: NSFetchRequest<PlanEntity> = PlanEntity.fetchRequest()
                request.predicate = NSPredicate(format: "uid == %@", planUID)
                
                if let entity = try context.fetch(request).first {
                    entity.memo = memo
                    try context.save()
                    print("PlanDAO, updateMemo // Success : Plan 메모 업데이트 완료 - \(planUID)")
                    return true
                } else {
                    print("PlanDAO, updateMemo // Warning : Plan을 찾을 수 없음 - \(planUID)")
                    return false
                }
            } catch {
                print("PlanDAO, updateMemo // Exception : \(error.localizedDescription)")
                return false
            }
        }
    }
    
    /// Plan 인덱스만 업데이트
    static func updateIndex(planUID: String, newIndex: Int, context: NSManagedObjectContext) -> Bool {
        guard validateContextSafety(context: context) else {
            print("PlanDAO, updateIndex // Exception : 잘못된 컨텍스트 스레드 사용")
            return false
        }
        
        return performSynchronously(on: context) {
            do {
                let request: NSFetchRequest<PlanEntity> = PlanEntity.fetchRequest()
                request.predicate = NSPredicate(format: "uid == %@", planUID)
                
                if let entity = try context.fetch(request).first {
                    entity.index = Int32(newIndex)
                    try context.save()
                    print("PlanDAO, updateIndex // Success : Plan 인덱스 업데이트 완료 - \(planUID) → \(newIndex)")
                    return true
                } else {
                    print("PlanDAO, updateIndex // Warning : Plan을 찾을 수 없음 - \(planUID)")
                    return false
                }
            } catch {
                print("PlanDAO, updateIndex // Exception : \(error.localizedDescription)")
                return false
            }
        }
    }
    
    /// Plan 삭제
    static func delete(planUID: String, context: NSManagedObjectContext) -> Bool {
        guard validateContextSafety(context: context) else {
            print("PlanDAO, delete // Exception : 잘못된 컨텍스트 스레드 사용")
            return false
        }
        
        return performSynchronously(on: context) {
            do {
                let request: NSFetchRequest<PlanEntity> = PlanEntity.fetchRequest()
                request.predicate = NSPredicate(format: "uid == %@", planUID)
                
                if let entity = try context.fetch(request).first {
                    context.delete(entity)
                    try context.save()
                    print("PlanDAO, delete // Success : Plan 삭제 완료 - \(planUID)")
                    return true
                } else {
                    print("PlanDAO, delete // Warning : Plan을 찾을 수 없음 - \(planUID)")
                    return false
                }
            } catch {
                print("PlanDAO, delete // Exception : \(error.localizedDescription)")
                return false
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private static func createPlanEntity(from plan: PlanModel, schedule: ScheduleEntity, context: NSManagedObjectContext) -> PlanEntity {
        let entity = PlanEntity(context: context)
        entity.uid = plan.uid
        entity.index = Int32(plan.index)
        entity.memo = plan.memo
        entity.schedule = schedule
        return entity
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

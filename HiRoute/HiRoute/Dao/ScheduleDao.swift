//
//  ScheduleDB.swift
//  HiRoute
//
//  Created by Jupond on 12/29/25.
//

import CoreData

struct ScheduleDAO {
    private init() {}
    
    /// Schedule 생성 - 비동기
    static func create(_ schedule: ScheduleModel, context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform { // 백그라운드 큐에서 비동기 실행
            do {
                // 중복검사 ( uid를 이용하여 중복검사, 동기식 헬퍼 사용 )
                if read(scheduleUID: schedule.uid, context: context) != nil {
                    print("ScheduleDAO, create // Warning : 이미 존재하는 일정 - \(schedule.uid)")
                    completion(false) // 중복이면 false를 completion으로 담아 보내고 return으로 종료
                    return
                }
                
                // coredata entity 생성
                let scheduleEntity = ScheduleEntity(context: context)
                scheduleEntity.uid = schedule.uid
                scheduleEntity.index = Int32(schedule.index)
                scheduleEntity.title = schedule.title
                scheduleEntity.memo = schedule.memo
                scheduleEntity.editDate = schedule.editDate
                scheduleEntity.d_day = schedule.d_day
                
                // 관련 plan entity들 생성 및 연결
                for plan in schedule.planList {
                    let planEntity = createPlanEntity(from: plan, schedule: scheduleEntity, context: context)
                    scheduleEntity.addToPlanList(planEntity) // core data 관계 설정
                }
                
                // 영구 저장소에 저장
                try context.save()
                print("ScheduleDAO, create // Success : 일정 저장 완료 - \(schedule.title)")
                completion(true) // 성공
            } catch {
                print("ScheduleDAO, create // Exception : \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    /// Schedule 업데이트 - 비동기
    static func update(_ schedule: ScheduleModel, context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform { // 백그라운드 큐에서 비동기 실행
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
                    completion(true)
                } else {
                    print("ScheduleDAO, update // Warning : 업데이트할 일정을 찾을 수 없음")
                    completion(false)
                }
            } catch {
                print("ScheduleDAO, update // Exception : \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    /// Schedule 삭제 - 비동기
    static func delete(scheduleUID: String, context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform {
            do {
                let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
                request.predicate = NSPredicate(format: "uid == %@", scheduleUID)
                
                if let entity = try context.fetch(request).first {
                    context.delete(entity)
                    try context.save()
                    print("ScheduleDAO, delete // Success : 일정 삭제 완료 - \(scheduleUID)")
                    completion(true)
                } else {
                    print("ScheduleDAO, delete // Warning : 일정을 찾을 수 없음 - \(scheduleUID)")
                    completion(false)
                }
            } catch {
                print("ScheduleDAO, delete // Exception : \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    /// Schedule 조회 - 비동기
    static func read(scheduleUID: String, context: NSManagedObjectContext, completion: @escaping (ScheduleModel?) -> Void) {
        context.perform { // 백그라운드 큐에서 비동기 실행
            do {
                // fetch request 생성
                let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
                request.predicate = NSPredicate(format: "uid == %@", scheduleUID)
                
                if let entity = try context.fetch(request).first {
                    let schedule = convertToScheduleModel(entity)
                    print("ScheduleDAO, read // Success : 일정 조회 완료 - \(scheduleUID)")
                    completion(schedule)
                } else {
                    completion(nil)
                }
            } catch {
                print("ScheduleDAO, read // Exception : \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    /// 모든 Schedule 조회 - 비동기
    static func readAll(context: NSManagedObjectContext, completion: @escaping ([ScheduleModel]) -> Void) {
        context.perform { // 백그라운드 큐에서 비동기 실행
            do {
                // fetch request 생성
                let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
                // 최신 편집순 (edit date)
                request.sortDescriptors = [NSSortDescriptor(key: "editDate", ascending: false)]
                
                // core data에서 모든 entity 조회
                let entities = try context.fetch(request)
                
                // entity -> model 변환
                let schedules = entities.compactMap { convertToScheduleModel($0) }
                print("ScheduleDAO, readAll // Success : 일정 목록 조회 완료 - \(entities.count)개")
                
                // model list 반환
                completion(schedules)
            } catch {
                print("ScheduleDAO, readAll // Exception : \(error.localizedDescription)")
                completion([]) // 실패시 empty list 반환
            }
        }
    }
    
    // MARK: - Helper Methods (동기식 - context.perform 내부에서만 호출)
    private static func read(scheduleUID: String, context: NSManagedObjectContext) -> ScheduleModel? {
        do {
            let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
            request.predicate = NSPredicate(format: "uid == %@", scheduleUID)
            
            if let entity = try context.fetch(request).first {
                return convertToScheduleModel(entity)
            }
            return nil
        } catch {
            print("ScheduleDAO, read // Exception : \(error.localizedDescription)")
            return nil
        }
    }
    
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

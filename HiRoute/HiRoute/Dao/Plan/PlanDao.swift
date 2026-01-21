//
//  PlanDB.swift
//  HiRoute
//
//  Created by Jupond on 12/29/25.
//
import CoreData

struct PlanDAO {
    private init() {}
    
    /// Plan 생성 - 비동기
    static func create(_ plan: PlanModel, scheduleUID: String, context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform { // 백그라운드 큐에서 비동기 실행
            do {
                // Schedule 존재 확인
                guard let scheduleEntity = fetchSchedule(uid: scheduleUID, context: context) else {
                    print("PlanDAO, create // Warning : Schedule을 찾을 수 없음 - \(scheduleUID)")
                    completion(false)
                    return
                }
                
                // 중복 검사
                if read(planUID: plan.uid, context: context) != nil {
                    print("PlanDAO, create // Warning : 이미 존재하는 Plan - \(plan.uid)")
                    completion(false)
                    return
                }
                
                // Core Data Entity 생성
                let planEntity = createPlanEntity(from: plan, schedule: scheduleEntity, context: context)
                scheduleEntity.addToPlanList(planEntity)
                
                // 영구 저장소에 저장
                try context.save()
                print("PlanDAO, create // Success : Plan 저장 완료 - \(plan.uid)")
                completion(true)
            } catch {
                print("PlanDAO, create // Exception : \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    /// Plan 조회 - 비동기
    static func read(planUID: String, context: NSManagedObjectContext, completion: @escaping (PlanModel?) -> Void) {
        context.perform { // 백그라운드 큐에서 비동기 실행
            do {
                let request: NSFetchRequest<PlanEntity> = PlanEntity.fetchRequest()
                request.predicate = NSPredicate(format: "uid == %@", planUID)
                
                if let entity = try context.fetch(request).first {
                    let plan = convertToPlanModel(entity)
                    print("PlanDAO, read // Success : Plan 조회 완료 - \(planUID)")
                    completion(plan)
                } else {
                    completion(nil)
                }
            } catch {
                print("PlanDAO, read // Exception : \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    /// Plan 목록 조회 - 비동기
    static func readAll(scheduleUID: String, context: NSManagedObjectContext, completion: @escaping ([PlanModel]) -> Void) {
        context.perform { // 백그라운드 큐에서 비동기 실행
            do {
                let request: NSFetchRequest<PlanEntity> = PlanEntity.fetchRequest()
                request.predicate = NSPredicate(format: "schedule.uid == %@", scheduleUID)
                request.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
                
                let entities = try context.fetch(request)
                let plans = entities.compactMap { convertToPlanModel($0) }
                print("PlanDAO, readAll // Success : Plan 목록 조회 완료 - \(entities.count)개")
                completion(plans)
            } catch {
                print("PlanDAO, readAll // Exception : \(error.localizedDescription)")
                completion([])
            }
        }
    }
    
    /// Plan 업데이트 - 비동기
    static func update(_ plan: PlanModel, context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform { // 백그라운드 큐에서 비동기 실행
            do {
                let request: NSFetchRequest<PlanEntity> = PlanEntity.fetchRequest()
                request.predicate = NSPredicate(format: "uid == %@", plan.uid)
                
                if let existingEntity = try context.fetch(request).first {
                    existingEntity.index = Int32(plan.index)
                    existingEntity.memo = plan.memo
                    
                    try context.save()
                    print("PlanDAO, update // Success : Plan 업데이트 완료 - \(plan.uid)")
                    completion(true)
                } else {
                    print("PlanDAO, update // Warning : Plan을 찾을 수 없음 - \(plan.uid)")
                    completion(false)
                }
            } catch {
                print("PlanDAO, update // Exception : \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    /// Plan 메모만 업데이트 - 비동기
    static func updateMemo(planUID: String, memo: String, context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform { // 백그라운드 큐에서 비동기 실행
            do {
                let request: NSFetchRequest<PlanEntity> = PlanEntity.fetchRequest()
                request.predicate = NSPredicate(format: "uid == %@", planUID)
                
                if let entity = try context.fetch(request).first {
                    entity.memo = memo
                    try context.save()
                    print("PlanDAO, updateMemo // Success : Plan 메모 업데이트 완료 - \(planUID)")
                    completion(true)
                } else {
                    print("PlanDAO, updateMemo // Warning : Plan을 찾을 수 없음 - \(planUID)")
                    completion(false)
                }
            } catch {
                print("PlanDAO, updateMemo // Exception : \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    /// Plan 인덱스만 업데이트 - 비동기
    static func updateIndex(planUID: String, newIndex: Int, context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform { // 백그라운드 큐에서 비동기 실행
            do {
                let request: NSFetchRequest<PlanEntity> = PlanEntity.fetchRequest()
                request.predicate = NSPredicate(format: "uid == %@", planUID)
                
                if let entity = try context.fetch(request).first {
                    entity.index = Int32(newIndex)
                    try context.save()
                    print("PlanDAO, updateIndex // Success : Plan 인덱스 업데이트 완료 - \(planUID) → \(newIndex)")
                    completion(true)
                } else {
                    print("PlanDAO, updateIndex // Warning : Plan을 찾을 수 없음 - \(planUID)")
                    completion(false)
                }
            } catch {
                print("PlanDAO, updateIndex // Exception : \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    /// Plan 삭제 - 비동기
    static func delete(planUID: String, context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform { // 백그라운드 큐에서 비동기 실행
            do {
                let request: NSFetchRequest<PlanEntity> = PlanEntity.fetchRequest()
                request.predicate = NSPredicate(format: "uid == %@", planUID)
                
                if let entity = try context.fetch(request).first {
                    context.delete(entity)
                    try context.save()
                    print("PlanDAO, delete // Success : Plan 삭제 완료 - \(planUID)")
                    completion(true)
                } else {
                    print("PlanDAO, delete // Warning : Plan을 찾을 수 없음 - \(planUID)")
                    completion(false)
                }
            } catch {
                print("PlanDAO, delete // Exception : \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    // MARK: - Helper Methods (동기식 - context.perform 내부에서만 호출)
    
    private static func read(planUID: String, context: NSManagedObjectContext) -> PlanModel? {
        do {
            let request: NSFetchRequest<PlanEntity> = PlanEntity.fetchRequest()
            request.predicate = NSPredicate(format: "uid == %@", planUID)
            
            if let entity = try context.fetch(request).first {
                return convertToPlanModel(entity)
            }
            return nil
        } catch {
            print("PlanDAO, read // Exception : \(error.localizedDescription)")
            return nil
        }
    }
    
    private static func fetchSchedule(uid: String, context: NSManagedObjectContext) -> ScheduleEntity? {
        do {
            let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
            request.predicate = NSPredicate(format: "uid == %@", uid)
            return try context.fetch(request).first
        } catch {
            print("PlanDAO, fetchSchedule // Exception : \(error.localizedDescription)")
            return nil
        }
    }
    
    private static func createPlanEntity(from plan: PlanModel, schedule: ScheduleEntity, context: NSManagedObjectContext) -> PlanEntity {
        let entity = PlanEntity(context: context)
        entity.uid = plan.uid
        entity.index = Int32(plan.index)
        entity.memo = plan.memo
        entity.schedule = schedule
        entity.placeModel = findOrCreatePlace(from: plan.placeModel, context: context)
        return entity
    }
    
    private static func findOrCreatePlace(from place: PlaceModel, context: NSManagedObjectContext) -> PlaceEntity {
        let request: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()
        request.predicate = NSPredicate(format: "uid == %@", place.uid)
        
        if let existing = try? context.fetch(request).first {
            return existing
        }
        
        // 신규 생성
        let placeEntity = PlaceEntity(context: context)
        placeEntity.uid = place.uid
        placeEntity.title = place.title
        placeEntity.type = place.type.rawValue
        placeEntity.subtitle = place.subtitle
        placeEntity.thumbnailImageURL = place.thumbnailImageURL
        return placeEntity
    }
    
    private static func convertToPlanModel(_ entity: PlanEntity) -> PlanModel? {
        guard let uid = entity.uid else { return nil }
        let place = entity.placeModel?.toPlaceModel() ?? PlaceModel.empty()
        
        return PlanModel(
            uid: uid,
            index: Int(entity.index),
            memo: entity.memo ?? "",
            placeModel: place,
            files: []
        )
    }
}

extension PlaceEntity {
    func toPlaceModel() -> PlaceModel {
        return PlaceModel(
            uid: uid ?? "",
            address: AddressModel(
                addressUID: "",
                addressLat: 0.0,
                addressLon: 0.0,
                addressTitle: "",
                sido: "",
                gungu: "",
                dong: "",
                fullAddress: ""
            ),
            type: PlaceType(rawValue: type ?? "") ?? .restaurant,
            title: title ?? "",
            subtitle: subtitle,
            thumbnailImageURL: thumbnailImageURL,
            workingTimes: [],
            reviews: [],
            bookMarks: [],
            stars: []
        )
    }
}

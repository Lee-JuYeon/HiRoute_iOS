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
        context.perform { // 백그라운드 큐에서 비동기 실행, NSManagedObjectContext는 스레드 안전하지 않음, perform으로 전요ㅗㅇ 큐 에서 실행 보장. 메인 스레드 블로킹 방지.
            do {
                /*
                 중복검사 ( uid를 이용하여 중복검사, 동기식 헬퍼 사용 )
                 DB에 SELECT 쿼리 실행
                 있으면 조기종료
                 */
                if read(scheduleUID: schedule.uid, context: context) != nil {
                    print("ScheduleDAO, create // Warning : 이미 존재하는 일정 - \(schedule.uid)")
                    completion(false) // 중복이면 false를 completion으로 담아 보내고 return으로 종료
                    return
                }
                
                /*
                 메모리에만 Entity 객체 생성 (아직 DB에 저장 안됨)
                 NSManagedObject 인스턴스 생성
                 Context에 "삽입 대기" 상태로 등록
                 */
                let scheduleEntity = ScheduleEntityMapper.toEntity(schedule, context: context)

            
                // 영구 저장소에 저장
                try context.save()
                completion(true) // 성공
                print("ScheduleDAO, create // Success : 일정 저장 완료 - \(schedule.title)")
            } catch {
                completion(false)
                print("ScheduleDAO, create // Exception : \(error.localizedDescription)")
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
            //  SELECT SQL 쿼리
            let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
            request.predicate = NSPredicate(format: "uid == %@", scheduleUID)
            
            if let entity = try context.fetch(request).first { //여기서 SQL 실행
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
        
        let placeEntity = createPlaceEntity(from: plan.placeModel, context: context)
        entity.placeModel = placeEntity
                
        return entity
    }
    
    private static func createPlaceEntity(from place: PlaceModel, context: NSManagedObjectContext) -> PlaceEntity {
        // 기존 Place 확인
        let request: NSFetchRequest<PlaceEntity> = PlaceEntity.fetchRequest()
        request.predicate = NSPredicate(format: "uid == %@", place.uid)
        
        if let existingPlace = try? context.fetch(request).first {
            return existingPlace // 기존 것 재사용
        }
        
        
        let entity = PlaceEntity(context: context)
        entity.uid = place.uid
        entity.title = place.title
        entity.subtitle = place.subtitle
        entity.thumbnailImageURL = place.thumbnailImageURL
        entity.type = place.type.rawValue // enum -> String
        
        // 🏠 AddressModel -> AddressEntity 생성
        for addressModel in [place.address] { // 배열로 처리 (1:N 관계)
            let addressEntity = AddressEntity(context: context)
            addressEntity.addressUID = addressModel.addressUID
            addressEntity.addressLat = addressModel.addressLat
            addressEntity.addressLon = addressModel.addressLon
            addressEntity.addressTitle = addressModel.addressTitle
            addressEntity.sido = addressModel.sido
            addressEntity.gungu = addressModel.gungu
            addressEntity.dong = addressModel.dong
            addressEntity.fullAddress = addressModel.fullAddress
            addressEntity.place = entity
            entity.addToAddress(addressEntity)
        }
        
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
        
        let placeModel = convertToPlaceModel(entity.placeModel) ?? PlaceModel.empty()
        
        return PlanModel(
            uid: uid,
            index: Int(entity.index),
            memo: entity.memo ?? "",
            placeModel: placeModel, //
            files: [] // TODO: FileEntity 처리
        )
    }
    
    private static func convertToPlaceModel(_ entity: PlaceEntity?) -> PlaceModel? {
        guard let entity = entity,
              let uid = entity.uid,
              let title = entity.title else { return nil }
        
        // AddressEntity -> AddressModel 변환 (첫 번째 주소만)
        let addressModel: AddressModel
        if let addressSet = entity.address as? Set<AddressEntity>,
           let firstAddress = addressSet.first {
            addressModel = AddressModel(
                addressUID: firstAddress.addressUID ?? "",
                addressLat: firstAddress.addressLat,
                addressLon: firstAddress.addressLon,
                addressTitle: firstAddress.addressTitle ?? "",
                sido: firstAddress.sido ?? "",
                gungu: firstAddress.gungu ?? "",
                dong: firstAddress.dong ?? "",
                fullAddress: firstAddress.fullAddress ?? ""
            )
        } else {
            // 주소가 없으면 기본값
            addressModel = AddressModel(
                addressUID: "", addressLat: 0.0, addressLon: 0.0,
                addressTitle: "", sido: "", gungu: "", dong: "", fullAddress: ""
            )
        }
        
        let workingTimes: [WorkingTimeModel]
        if let workingTimeSet = entity.workingTimes as? Set<WorkingTimeEntity> {
            workingTimes = workingTimeSet.compactMap { workingTimeEntity in
                guard let id = workingTimeEntity.id else { return nil }
                return WorkingTimeModel(
                    id: id,
                    dayTitle: workingTimeEntity.dayTitle ?? "",
                    open: workingTimeEntity.open ?? "",
                    close: workingTimeEntity.close ?? "",
                    lastOrder: workingTimeEntity.lastOrder ?? ""
                )
            }
        } else {
            workingTimes = []
        }
        
        // ReviewEntity -> ReviewModel 변환 (완전한 데이터 포함)
        let reviews: [ReviewModel]
        if let reviewSet = entity.reviews as? Set<ReviewEntity> {
            reviews = reviewSet.compactMap { reviewEntity in
                guard let reviewUID = reviewEntity.reviewUID else { return nil }
                
                //  ReviewImageEntity -> ReviewImageModel 변환
                let images: [ReviewImageModel]
                if let imageSet = reviewEntity.images as? Set<ReviewImageEntity> {
                    images = imageSet.compactMap { imageEntity in
                        guard let uid = imageEntity.uid,
                              let userUID = imageEntity.userUID,
                              let imageURL = imageEntity.imageURL else { return nil }
                        
                        return ReviewImageModel(
                            uid: uid,
                            userUID: userUID,
                            date: imageEntity.date ?? Date(),
                            imageURL: imageURL
                        )
                    }
                } else {
                    images = []
                }
                
                // UsefulEntity -> UsefulModel 변환
                let usefulList: [UsefulModel]
                if let usefulSet = reviewEntity.usefulList as? Set<UsefulEntity> {
                    usefulList = usefulSet.compactMap { usefulEntity in
                        guard let userUID = usefulEntity.userUID else { return nil }
                        return UsefulModel(userUID: userUID)
                    }
                } else {
                    usefulList = []
                }
                
                return ReviewModel(
                    reviewUID: reviewUID,
                    reviewText: reviewEntity.reviewText ?? "",
                    userUID: reviewEntity.userUID ?? "",
                    userName: reviewEntity.userName ?? "",
                    visitDate: reviewEntity.visitDate ?? Date(),
                    usefulCount: Int(reviewEntity.usefulCount),
                    images: images,
                    usefulList: usefulList
                )
            }
        } else {
            reviews = []
        }
        
        let bookMarks: [BookMarkModel]
        if let bookmarkSet = entity.bookMarks as? Set<BookmarkEntity> {
            bookMarks = bookmarkSet.compactMap { bookmarkEntity in
                guard let userUID = bookmarkEntity.userUID else { return nil }
                return BookMarkModel(userUID: userUID)
            }
        } else {
            bookMarks = []
        }
        
        let stars: [StarModel]
        if let starSet = entity.stars as? Set<StarEntity> {
            stars = starSet.compactMap { starEntity in
                guard let userUID = starEntity.userUID else { return nil }
                return StarModel(
                    userUID: userUID,
                    star: Int(starEntity.star)
                )
            }
        } else {
            stars = []
        }
        
        return PlaceModel(
            uid: uid,
            address: addressModel,
            type: PlaceType(rawValue: entity.type ?? "") ?? .restaurant,
            title: title,
            subtitle: entity.subtitle,
            thumbnailImageURL: entity.thumbnailImageURL,
            workingTimes: workingTimes,
            reviews: reviews,
            bookMarks: bookMarks,
            stars: stars               
        )
    }
}

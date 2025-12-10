//
//  RouteRepositoryProtocol.swift
//  HiRoute
//
//  Created by Jupond on 7/26/25.
//
import Combine
import Foundation
import CoreData

/*
 MVVM + Service Layer에서의 respotiroy의 역할
 - 캐시 관리
 - 로컬 저장소 관리
 - 서버 통신 시뮬레이션
 - CRUD 오퍼레이션
 */

class ScheduleRepository: ScheduleProtocol {
    
    private let mainContext = CoreDataStack.shared.context
    private let backgroundContext: NSManagedObjectContext
    
    init() {
        backgroundContext = CoreDataStack.shared.persistentContainer.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        // 메모리 최적화 설정
        backgroundContext.undoManager = nil
        backgroundContext.shouldDeleteInaccessibleFaults = true
        print("ScheduleRepository, init // Success : 비동기 초기화 완료")
    }
    
    // MARK: - CRUD Operations
    func create(_ scheduleModel: ScheduleModel) -> AnyPublisher<ScheduleModel, Error> {
        return Future<ScheduleModel, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(ScheduleError.unknown))
                return
            }
            
            self.backgroundContext.perform {
                do {
                    // 중복 확인 (메모리 효율적)
                    if try self.checkDuplicateEfficient(uid: scheduleModel.uid) {
                        promise(.failure(ScheduleError.duplicateSchedule))
                        return
                    }
                    
                    let scheduleEntity = ScheduleEntity(context: self.backgroundContext)
                    self.mapModelToEntity(scheduleModel, entity: scheduleEntity, context: self.backgroundContext)
                    
                    try self.backgroundContext.save()
                    print("ScheduleRepository, create // Success : 비동기 일정 생성 - \(scheduleModel.title)")
                    promise(.success(scheduleModel))
                    
                } catch {
                    self.backgroundContext.rollback()
                    print("ScheduleRepository, create // Exception : \(error.localizedDescription)")
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func read(scheduleUID: String) -> AnyPublisher<ScheduleModel, Error> {
        return Future<ScheduleModel, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(ScheduleError.unknown))
                return
            }
            
            self.backgroundContext.perform {
                do {
                    let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
                    request.predicate = NSPredicate(format: "uid == %@", scheduleUID)
                    request.fetchLimit = 1
                    request.returnsObjectsAsFaults = false // 메모리 최적화
                    
                    if let entity = try self.backgroundContext.fetch(request).first,
                       let schedule = self.convertToModel(entity) {
                        print("ScheduleRepository, read // Success : 비동기 일정 조회 - \(scheduleUID)")
                        promise(.success(schedule))
                    } else {
                        print("ScheduleRepository, read // Warning : 일정을 찾을 수 없음 - \(scheduleUID)")
                        promise(.failure(ScheduleError.notFound))
                    }
                } catch {
                    print("ScheduleRepository, read // Exception : \(error.localizedDescription)")
                    promise(.failure(ScheduleError.unknown))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func readList(page: Int, itemsPerPage: Int) -> AnyPublisher<[ScheduleModel], Error> {
        return Future<[ScheduleModel], Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(ScheduleError.unknown))
                return
            }
            
            self.backgroundContext.perform {
                do {
                    let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
                    request.sortDescriptors = [NSSortDescriptor(key: "editDate", ascending: false)]
                    
                    // 페이지네이션 설정
                    request.fetchOffset = page * itemsPerPage
                    request.fetchLimit = itemsPerPage
                    request.fetchBatchSize = itemsPerPage
                    
                    // 메모리 최적화 설정
                    request.returnsObjectsAsFaults = true
                    request.includesPropertyValues = true
                    request.includesSubentities = false
                    
                    let entities = try self.backgroundContext.fetch(request)
                    var schedules: [ScheduleModel] = []
                    
                    // 배치별 메모리 관리
                    for (index, entity) in entities.enumerated() {
                        if let schedule = self.convertToModel(entity) {
                            schedules.append(schedule)
                        }
                        
                        // 주기적 메모리 정리
                        if index % 10 == 0 && index > 0 {
                            self.backgroundContext.refreshAllObjects()
                        }
                    }
                    
                    print("ScheduleRepository, readList // Success : 페이지 조회 - page:\(page), count:\(schedules.count)")
                    promise(.success(schedules))
                    
                } catch {
                    print("ScheduleRepository, readList // Exception : \(error.localizedDescription)")
                    promise(.failure(ScheduleError.unknown))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func update(_ scheduleModel: ScheduleModel) -> AnyPublisher<ScheduleModel, Error> {
        return Future<ScheduleModel, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(ScheduleError.unknown))
                return
            }
            
            self.backgroundContext.perform {
                do {
                    let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
                    request.predicate = NSPredicate(format: "uid == %@", scheduleModel.uid)
                    request.fetchLimit = 1
                    
                    guard let entity = try self.backgroundContext.fetch(request).first else {
                        promise(.failure(ScheduleError.notFound))
                        return
                    }
                    
                    self.cleanupExistingRelations(entity: entity, context: self.backgroundContext)
                    self.mapModelToEntity(scheduleModel, entity: entity, context: self.backgroundContext)
                    
                    try self.backgroundContext.save()
                    print("ScheduleRepository, update // Success : 비동기 일정 업데이트 - \(scheduleModel.title)")
                    promise(.success(scheduleModel))
                    
                } catch {
                    self.backgroundContext.rollback()
                    print("ScheduleRepository, update // Exception : \(error.localizedDescription)")
                    promise(.failure(ScheduleError.updateFailed))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func delete(scheduleUID: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(ScheduleError.unknown))
                return
            }
            
            self.backgroundContext.perform {
                do {
                    let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
                    request.predicate = NSPredicate(format: "uid == %@", scheduleUID)
                    request.fetchLimit = 1
                    
                    guard let entity = try self.backgroundContext.fetch(request).first else {
                        promise(.failure(ScheduleError.notFound))
                        return
                    }
                    
                    self.backgroundContext.delete(entity)
                    try self.backgroundContext.save()
                    
                    print("ScheduleRepository, delete // Success : 비동기 일정 삭제 - \(scheduleUID)")
                    promise(.success(()))
                    
                } catch {
                    self.backgroundContext.rollback()
                    print("ScheduleRepository, delete // Exception : \(error.localizedDescription)")
                    promise(.failure(ScheduleError.unknown))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    
    /// 장소 개수 제한 체크 (비즈니스 룰)
    func checkPlaceLimit(for scheduleModel: ScheduleModel) -> Result<Void, ScheduleError> {
        if scheduleModel.visitPlaceList.count >= 20 {
            print("ScheduleRepository, checkPlaceLimit // Warning : 최대 장소 수 초과 - \(scheduleModel.visitPlaceList.count)개")
            return .failure(.maxPlacesReached)
        }
        return .success(())
    }
    
    /// 중복 장소 체크 (비즈니스 룰)
    func checkDuplicatePlace(placeUID: String, in scheduleModel: ScheduleModel) -> Result<Void, ScheduleError> {
        if scheduleModel.visitPlaceList.contains(where: { $0.placeModel.uid == placeUID }) {
            print("ScheduleRepository, checkDuplicatePlace // Warning : 중복 장소 추가 시도 - \(placeUID)")
            return .failure(.duplicatePlace)
        }
        return .success(())
    }
    
    /// 메모리 효율적 중복 확인 (객체 로드 없이)
    private func checkDuplicateEfficient(uid: String) throws -> Bool {
        let request: NSFetchRequest<NSNumber> = NSFetchRequest(entityName: "ScheduleEntity")
        request.predicate = NSPredicate(format: "uid == %@", uid)
        request.resultType = .countResultType
        
        let results = try backgroundContext.fetch(request)
        return (results.first?.intValue ?? 0) > 0
    }
    
    /// 기존 관계 정리 (메모리 효율적)
    private func cleanupExistingRelations(entity: ScheduleEntity, context: NSManagedObjectContext) {
        if let visitPlaces = entity.visitPlaceList as? Set<VisitPlaceEntity> {
            let deleteCount = visitPlaces.count
            for visitPlace in visitPlaces {
                context.delete(visitPlace)
            }
            print("ScheduleRepository, cleanupExistingRelations // Info : 기존 관계 \(deleteCount)개 정리")
        }
    }
    
    /// Model → Entity 매핑
    private func mapModelToEntity(_ model: ScheduleModel, entity: ScheduleEntity, context: NSManagedObjectContext) {
        entity.uid = model.uid
        entity.index = Int32(model.index)
        entity.title = model.title
        entity.memo = model.memo
        entity.editDate = model.editDate
        entity.d_day = model.d_day
        
        for visitPlace in model.visitPlaceList {
            let visitEntity = createVisitPlaceEntity(from: visitPlace, schedule: entity, context: context)
            entity.addToVisitPlaceList(visitEntity)
        }
    }
       
    /// VisitPlaceEntity 생성
    private func createVisitPlaceEntity(from visitPlace: VisitPlaceModel, schedule: ScheduleEntity, context: NSManagedObjectContext) -> VisitPlaceEntity {
        let visitEntity = VisitPlaceEntity(context: context)
        visitEntity.uid = visitPlace.uid
        visitEntity.index = Int32(visitPlace.index)
        visitEntity.memo = visitPlace.memo
        visitEntity.schedule = schedule
        
        // TODO: PlaceEntity, FileEntity 연결 (PlaceRepository에서 처리)
        return visitEntity
    }
    
    /// Entity → Model 변환
    private func convertToModel(_ entity: ScheduleEntity) -> ScheduleModel? {
        guard let uid = entity.uid,
              let title = entity.title,
              let editDate = entity.editDate,
              let dDay = entity.d_day else {
            print("ScheduleRepository, convertToModel // Warning : 필수 필드 누락")
            return nil
        }
        
        var visitPlaceList: [VisitPlaceModel] = []
        
        if let visitPlaces = entity.visitPlaceList as? Set<VisitPlaceEntity> {
            let sortedVisitPlaces = visitPlaces.sorted { $0.index < $1.index }
            visitPlaceList = sortedVisitPlaces.compactMap { convertToVisitPlaceModel($0) }
        }
        
        return ScheduleModel(
            uid: uid,
            index: Int(entity.index),
            title: title,
            memo: entity.memo ?? "",
            editDate: editDate,
            d_day: dDay,
            visitPlaceList: visitPlaceList
        )
    }
    
    /// VisitPlaceEntity → VisitPlaceModel 변환
    private func convertToVisitPlaceModel(_ entity: VisitPlaceEntity) -> VisitPlaceModel? {
        guard let uid = entity.uid else { return nil }
        
        return VisitPlaceModel(
            uid: uid,
            index: Int(entity.index),
            memo: entity.memo ?? "",
            placeModel: PlaceModel.empty(),
            files: []
        )
    }
    
    // MARK: - Memory Management
    
    /// 메모리 정리
    func clearMemoryCache() {
        backgroundContext.perform { [weak self] in
            self?.backgroundContext.refreshAllObjects()
            print("ScheduleRepository, clearMemoryCache // Success : 메모리 캐시 정리 완료")
        }
    }
    
    deinit {
        clearMemoryCache()
        print("ScheduleRepository, deinit // Success : Repository 해제 완료")
    }
}

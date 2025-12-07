//
//  ScheduleCreateManager.swift
//  HiRoute
//
//  Created by Jupond on 12/5/25.
//
import CoreData
import Foundation
import Combine

/**
 * VisitPlaceRepository
 * - VisitPlace 도메인의 CoreData 액세스 구현체
 * - Schedule과 Place 간의 다대다 관계를 중간 테이블로 관리
 * - 비동기 처리로 메인스레드 블로킹 방지
 */
class VisitPlaceRepository: VisitPlaceProtocol {
    
    // MARK: - CoreData Contexts
    private let mainContext = CoreDataStack.shared.context
    private let backgroundContext: NSManagedObjectContext
    
    init() {
        backgroundContext = CoreDataStack.shared.persistentContainer.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
        // 메모리 최적화 설정
        backgroundContext.undoManager = nil
        backgroundContext.shouldDeleteInaccessibleFaults = true
        print("VisitPlaceRepository, init // Success : 비동기 초기화 완료")
    }
    
    // MARK: - CRUD Implementation
    
    /**
     * 새 방문장소 생성
     * - VisitPlaceEntity와 연관 관계 설정
     * - Schedule과 Place 연결 설정
     * - 백그라운드 컨텍스트에서 비동기 실행
     */
    func create(_ visitPlace: VisitPlaceModel) -> AnyPublisher<VisitPlaceModel, Error> {
        return Future<VisitPlaceModel, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(ScheduleError.unknown))
                return
            }
            
            self.backgroundContext.perform {
                do {
                    // 중복 확인
                    if try self.checkDuplicateEfficient(uid: visitPlace.uid) {
                        promise(.failure(ScheduleError.duplicatePlace))
                        return
                    }
                    
                    let visitPlaceEntity = VisitPlaceEntity(context: self.backgroundContext)
                    self.mapModelToEntity(visitPlace, entity: visitPlaceEntity, context: self.backgroundContext)
                    
                    try self.backgroundContext.save()
                    print("VisitPlaceRepository, create // Success : 방문장소 생성 - \(visitPlace.uid)")
                    promise(.success(visitPlace))
                    
                } catch {
                    self.backgroundContext.rollback()
                    print("VisitPlaceRepository, create // Exception : \(error.localizedDescription)")
                    promise(.failure(ScheduleError.saveFailed))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    /**
     * 특정 방문장소 조회
     * - Place 정보와 File 정보도 함께 조회하여 완전한 모델 반환
     * - 메모리 효율적인 Fault 객체 사용
     */
    func read(uid: String) -> AnyPublisher<VisitPlaceModel, Error> {
        return Future<VisitPlaceModel, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(ScheduleError.unknown))
                return
            }
            
            self.backgroundContext.perform {
                do {
                    let request: NSFetchRequest<VisitPlaceEntity> = VisitPlaceEntity.fetchRequest()
                    request.predicate = NSPredicate(format: "uid == %@", uid)
                    request.fetchLimit = 1
                    request.returnsObjectsAsFaults = false
                    
                    if let entity = try self.backgroundContext.fetch(request).first,
                       let visitPlace = self.convertToModel(entity) {
                        print("VisitPlaceRepository, read // Success : 방문장소 조회 - \(uid)")
                        promise(.success(visitPlace))
                    } else {
                        print("VisitPlaceRepository, read // Warning : 방문장소를 찾을 수 없음 - \(uid)")
                        promise(.failure(ScheduleError.notFound))
                    }
                } catch {
                    print("VisitPlaceRepository, read // Exception : \(error.localizedDescription)")
                    promise(.failure(ScheduleError.unknown))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    /**
     * 특정 일정의 모든 방문장소 조회
     * - Schedule UID로 연결된 모든 VisitPlace 조회
     * - index 순서로 정렬하여 올바른 방문 순서 보장
     */
    func readAll(scheduleUID: String) -> AnyPublisher<[VisitPlaceModel], Error> {
        return Future<[VisitPlaceModel], Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(ScheduleError.unknown))
                return
            }
            
            self.backgroundContext.perform {
                do {
                    let request: NSFetchRequest<VisitPlaceEntity> = VisitPlaceEntity.fetchRequest()
                    request.predicate = NSPredicate(format: "schedule.uid == %@", scheduleUID)
                    request.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
                    
                    // 메모리 최적화 설정
                    request.fetchBatchSize = 20
                    request.returnsObjectsAsFaults = true
                    
                    let entities = try self.backgroundContext.fetch(request)
                    let visitPlaces = entities.compactMap { self.convertToModel($0) }
                    
                    print("VisitPlaceRepository, readAll // Success : 방문장소 목록 조회 - \(visitPlaces.count)개")
                    promise(.success(visitPlaces))
                    
                } catch {
                    print("VisitPlaceRepository, readAll // Exception : \(error.localizedDescription)")
                    promise(.failure(ScheduleError.unknown))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    /**
     * 방문장소 정보 수정
     * - memo, index 등 VisitPlace 고유 속성 수정
     * - 관련 File 정보도 함께 업데이트
     */
    func update(_ visitPlace: VisitPlaceModel) -> AnyPublisher<VisitPlaceModel, Error> {
        return Future<VisitPlaceModel, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(ScheduleError.unknown))
                return
            }
            
            self.backgroundContext.perform {
                do {
                    let request: NSFetchRequest<VisitPlaceEntity> = VisitPlaceEntity.fetchRequest()
                    request.predicate = NSPredicate(format: "uid == %@", visitPlace.uid)
                    request.fetchLimit = 1
                    
                    guard let entity = try self.backgroundContext.fetch(request).first else {
                        promise(.failure(ScheduleError.notFound))
                        return
                    }
                    
                    // 기존 File 관계 정리
                    self.cleanupExistingFiles(entity: entity, context: self.backgroundContext)
                    
                    // 새 데이터로 매핑
                    self.mapModelToEntity(visitPlace, entity: entity, context: self.backgroundContext)
                    
                    try self.backgroundContext.save()
                    print("VisitPlaceRepository, update // Success : 방문장소 업데이트 - \(visitPlace.uid)")
                    promise(.success(visitPlace))
                    
                } catch {
                    self.backgroundContext.rollback()
                    print("VisitPlaceRepository, update // Exception : \(error.localizedDescription)")
                    promise(.failure(ScheduleError.updateFailed))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    /**
     * 방문장소 삭제
     * - VisitPlace와 연결된 File들도 Cascade 삭제
     * - Schedule과 Place는 그대로 유지 (연결만 해제)
     */
    func delete(uid: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(ScheduleError.unknown))
                return
            }
            
            self.backgroundContext.perform {
                do {
                    let request: NSFetchRequest<VisitPlaceEntity> = VisitPlaceEntity.fetchRequest()
                    request.predicate = NSPredicate(format: "uid == %@", uid)
                    request.fetchLimit = 1
                    
                    guard let entity = try self.backgroundContext.fetch(request).first else {
                        promise(.failure(ScheduleError.notFound))
                        return
                    }
                    
                    self.backgroundContext.delete(entity)
                    try self.backgroundContext.save()
                    
                    print("VisitPlaceRepository, delete // Success : 방문장소 삭제 - \(uid)")
                    promise(.success(()))
                    
                } catch {
                    self.backgroundContext.rollback()
                    print("VisitPlaceRepository, delete // Exception : \(error.localizedDescription)")
                    promise(.failure(ScheduleError.unknown))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Methods
    
    /**
     * 메모리 효율적 중복 확인
     * - 객체를 로드하지 않고 개수만 확인하여 메모리 절약
     */
    private func checkDuplicateEfficient(uid: String) throws -> Bool {
        let request: NSFetchRequest<NSNumber> = NSFetchRequest(entityName: "VisitPlaceEntity")
        request.predicate = NSPredicate(format: "uid == %@", uid)
        request.resultType = .countResultType
        
        let results = try backgroundContext.fetch(request)
        return (results.first?.intValue ?? 0) > 0
    }
    
    /**
     * 기존 File 관계 정리
     * - 업데이트시 기존 File들을 삭제하고 새로 생성
     */
    private func cleanupExistingFiles(entity: VisitPlaceEntity, context: NSManagedObjectContext) {
        if let files = entity.files as? Set<FileEntity> {
            let deleteCount = files.count
            for file in files {
                context.delete(file)
            }
            print("VisitPlaceRepository, cleanupExistingFiles // Info : 기존 파일 \(deleteCount)개 정리")
        }
    }
    
    /**
     * Model → Entity 매핑
     * - VisitPlace 속성과 File 관계 설정
     */
    private func mapModelToEntity(_ model: VisitPlaceModel, entity: VisitPlaceEntity, context: NSManagedObjectContext) {
        entity.uid = model.uid
        entity.index = Int32(model.index)
        entity.memo = model.memo
        
        // File 관계 설정
        for file in model.files {
            let fileEntity = createFileEntity(from: file, visitPlace: entity, context: context)
            entity.addToFiles(fileEntity)
        }
        
        // TODO: PlaceEntity 연결 (PlaceRepository 구현 후 처리)
    }
    
    /**
     * FileEntity 생성
     * - FileModel → FileEntity 변환
     */
    private func createFileEntity(from file: FileModel, visitPlace: VisitPlaceEntity, context: NSManagedObjectContext) -> FileEntity {
        let fileEntity = FileEntity(context: context)
        fileEntity.id = file.id.uuidString
        fileEntity.fileName = file.fileName
        fileEntity.fileType = file.fileType
        fileEntity.fileSize = file.fileSize
        fileEntity.filePath = file.filePath
        fileEntity.createdDate = file.createdDate
        fileEntity.visitPlace = visitPlace
        
        return fileEntity
    }
    
    /**
     * Entity → Model 변환
     * - 완전한 VisitPlace 정보 구성 (Place + File 포함)
     */
    private func convertToModel(_ entity: VisitPlaceEntity) -> VisitPlaceModel? {
        guard let uid = entity.uid else { return nil }
        
        // File 변환
        var files: [FileModel] = []
        if let fileSet = entity.files as? Set<FileEntity> {
            let sortedFiles = fileSet.sorted { $0.createdDate ?? Date() < $1.createdDate ?? Date() }
            files = sortedFiles.compactMap { convertToFileModel($0) }
        }
        
        return VisitPlaceModel(
            uid: uid,
            index: Int(entity.index),
            memo: entity.memo ?? "",
            placeModel: PlaceModel.empty(), // TODO: 실제 PlaceModel 변환 (PlaceRepository 구현 후)
            files: files
        )
    }
    
    /**
     * FileEntity → FileModel 변환
     */
    private func convertToFileModel(_ entity: FileEntity) -> FileModel? {
        guard let idString = entity.id,
              let uuid = UUID(uuidString: idString) else { return nil }
        
        var fileModel = FileModel(
            fileName: entity.fileName ?? "",
            fileType: entity.fileType ?? "",
            fileSize: entity.fileSize,
            filePath: entity.filePath ?? "",
            createdDate: entity.createdDate ?? Date()
        )
        fileModel.id = uuid
        
        return fileModel
    }
    
    deinit {
        print("VisitPlaceRepository, deinit // Success : VisitPlace Repository 해제 완료")
    }
}

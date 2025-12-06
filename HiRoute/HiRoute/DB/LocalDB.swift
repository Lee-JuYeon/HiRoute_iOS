//
//  Untitled.swift
//  HiRoute
//
//  Created by Jupond on 12/5/25.
//

import CoreData
import Foundation

class LocalDB {
    private let context = CoreDataStack.shared.context
    
    // MARK: - CRUD Operations
    
    /// 일정 저장
    func save(_ schedule: ScheduleModel) {
        // 중복 확인
        if load(uid: schedule.uid) != nil {
            print("⚠️ 이미 존재하는 일정: \(schedule.uid)")
            return
        }
        
        let scheduleEntity = ScheduleEntity(context: context)
        scheduleEntity.uid = schedule.uid
        scheduleEntity.index = Int32(schedule.index)
        scheduleEntity.title = schedule.title
        scheduleEntity.memo = schedule.memo
        scheduleEntity.editDate = schedule.editDate
        scheduleEntity.d_day = schedule.d_day
        
        // VisitPlace들 저장
        for visitPlace in schedule.visitPlaceList {
            let visitEntity = createVisitPlaceEntity(from: visitPlace, schedule: scheduleEntity)
            scheduleEntity.addToVisitPlaceList(visitEntity)
        }
        
        CoreDataStack.shared.saveContext()
        print("💾 일정 저장: \(schedule.title)")
    }
    
    /// 일정 업데이트
    func update(_ schedule: ScheduleModel) {
        let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
        request.predicate = NSPredicate(format: "uid == %@", schedule.uid)
        
        do {
            if let existingEntity = try context.fetch(request).first {
                // 기존 관계 데이터 삭제
                if let visitPlaces = existingEntity.visitPlaceList as? Set<VisitPlaceEntity> {
                    for visitPlace in visitPlaces {
                        context.delete(visitPlace)
                    }
                }
                
                // 업데이트
                existingEntity.title = schedule.title
                existingEntity.memo = schedule.memo
                existingEntity.editDate = schedule.editDate
                existingEntity.d_day = schedule.d_day
                existingEntity.index = Int32(schedule.index)
                
                // 새 VisitPlace들 추가
                for visitPlace in schedule.visitPlaceList {
                    let visitEntity = createVisitPlaceEntity(from: visitPlace, schedule: existingEntity)
                    existingEntity.addToVisitPlaceList(visitEntity)
                }
                
                CoreDataStack.shared.saveContext()
                print("🔄 일정 업데이트: \(schedule.title)")
            } else {
                save(schedule)
            }
        } catch {
            print("❌ 업데이트 실패: \(error)")
        }
    }
    
    /// 일정 삭제
    func delete(uid: String) {
        let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
        request.predicate = NSPredicate(format: "uid == %@", uid)
        
        do {
            if let entity = try context.fetch(request).first {
                context.delete(entity)
                CoreDataStack.shared.saveContext()
                print("🗑️ 일정 삭제: \(uid)")
            }
        } catch {
            print("❌ 삭제 실패: \(error)")
        }
    }
    
    /// 특정 일정 로드
    func load(uid: String) -> ScheduleModel? {
        let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
        request.predicate = NSPredicate(format: "uid == %@", uid)
        
        do {
            if let entity = try context.fetch(request).first {
                return convertToScheduleModel(entity)
            }
        } catch {
            print("❌ 로드 실패: \(error)")
        }
        
        return nil
    }
    
    /// 모든 일정 로드
    func loadAll() -> [ScheduleModel] {
        let request: NSFetchRequest<ScheduleEntity> = ScheduleEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "editDate", ascending: false)]
        
        do {
            let entities = try context.fetch(request)
            return entities.compactMap { convertToScheduleModel($0) }
        } catch {
            print("❌ 전체 로드 실패: \(error)")
            return []
        }
    }
    
    // MARK: - Private Helpers
    
    private func createVisitPlaceEntity(from visitPlace: VisitPlaceModel, schedule: ScheduleEntity) -> VisitPlaceEntity {
        let visitEntity = VisitPlaceEntity(context: context)
        visitEntity.uid = visitPlace.uid
        visitEntity.index = Int32(visitPlace.index)
        visitEntity.memo = visitPlace.memo
        visitEntity.schedule = schedule
        
        // TODO: PlaceEntity, FileEntity 연결
        
        return visitEntity
    }
    
    private func convertToScheduleModel(_ entity: ScheduleEntity) -> ScheduleModel? {
        // TODO: 완전한 변환 로직
        return ScheduleModel(
            uid: entity.uid ?? "",
            index: Int(entity.index),
            title: entity.title ?? "",
            memo: entity.memo ?? "",
            editDate: entity.editDate ?? Date(),
            d_day: entity.d_day ?? Date(),
            visitPlaceList: []
        )
    }
}

//
//  PlanEntityMapper.swift
//  HiRoute
//
//  Created by Jupond on 1/21/26.
//

import CoreData

struct PlanEntityMapper {
    static func toModel(_ entity: PlanEntity?, fullData: Bool = true) -> PlanModel? {
        guard let entity = entity,
              let uid = entity.uid else { return nil }
        
        // PlaceEntity -> PlaceModel 변환 (항상 전체 데이터)
        let placeModel = PlaceEntityMapper.toModel(entity.placeModel, fullData: fullData) ?? PlaceModel.empty()
        
        // FileEntity -> FileModel 변환
        let files = FileEntityMapper.toModels(entity.files as? Set<FileEntity>)
        
        return PlanModel(
            uid: uid,
            index: Int(entity.index),
            memo: entity.memo ?? "",
            placeModel: placeModel,
            files: files // ✅ 실제 파일 데이터
        )
    }
    
    static func toModels(_ entities: Set<PlanEntity>?, fullData: Bool = true) -> [PlanModel] {
        guard let entities = entities else { return [] }
        
        let sortedPlans = entities.sorted { $0.index < $1.index }
        return sortedPlans.compactMap { toModel($0, fullData: fullData) }
    }
    
    static func toEntity(_ model: PlanModel, schedule: ScheduleEntity, context: NSManagedObjectContext) -> PlanEntity {
        let entity = PlanEntity(context: context)
        entity.uid = model.uid
        entity.index = Int32(model.index)
        entity.memo = model.memo
        entity.schedule = schedule
        
        // PlaceEntity 생성 및 연결
        let placeEntity = PlaceEntityMapper.toEntity(model.placeModel, context: context)
        entity.placeModel = placeEntity
        
        // FileEntity 생성 및 연결
        let fileEntities = FileEntityMapper.toEntitiesForPlan(model.files, planEntity: entity, context: context)
        for fileEntity in fileEntities {
            entity.addToFiles(fileEntity)
        }
        
        return entity
    }
}


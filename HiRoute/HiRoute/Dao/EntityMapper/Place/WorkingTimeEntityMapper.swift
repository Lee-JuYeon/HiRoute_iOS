//
//  WorkingTimeEntityMapper.swift
//  HiRoute
//
//  Created by Jupond on 1/21/26.
//

import CoreData

struct WorkingTimeEntityMapper {
    static func toModel(_ entity: WorkingTimeEntity?) -> WorkingTimeModel? {
        guard let entity = entity,
              let id = entity.id else { return nil }
        
        return WorkingTimeModel(
            id: id,
            dayTitle: entity.dayTitle ?? "",
            open: entity.open ?? "",
            close: entity.close ?? "",
            lastOrder: entity.lastOrder ?? ""
        )
    }
    
    static func toModels(_ entities: Set<WorkingTimeEntity>?) -> [WorkingTimeModel] {
        guard let entities = entities else { return [] }
        
        return entities.compactMap { toModel($0) }
    }
    
    static func toEntity(_ model: WorkingTimeModel, context: NSManagedObjectContext) -> WorkingTimeEntity {
        let entity = WorkingTimeEntity(context: context)
        entity.id = model.id
        entity.dayTitle = model.dayTitle
        entity.open = model.open
        entity.close = model.close
        entity.lastOrder = model.lastOrder
        return entity
    }
}

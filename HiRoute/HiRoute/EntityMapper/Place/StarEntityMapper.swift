//
//  StarEntityMapper.swift
//  HiRoute
//
//  Created by Jupond on 1/21/26.
//

import CoreData

struct StarEntityMapper {
    static func toModel(_ entity: StarEntity?) -> StarModel? {
        guard let entity = entity,
              let userUID = entity.userUID else { return nil }
        
        return StarModel(
            userUID: userUID,
            star: Int(entity.star)
        )
    }
    
    static func toModels(_ entities: Set<StarEntity>?) -> [StarModel] {
        guard let entities = entities else { return [] }
        
        return entities.compactMap { toModel($0) }
    }
    
    static func toEntity(_ model: StarModel, context: NSManagedObjectContext) -> StarEntity {
        let entity = StarEntity(context: context)
        entity.userUID = model.userUID
        entity.star = Int32(model.star)
        return entity
    }
}

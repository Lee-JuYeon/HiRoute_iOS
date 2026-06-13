//
//  BookMarkEntityMapper.swift
//  HiRoute
//
//  Created by Jupond on 1/21/26.
//

import CoreData

struct BookmarkEntityMapper {
    static func toModel(_ entity: BookmarkEntity?) -> BookMarkModel? {
        guard let entity = entity,
              let userUID = entity.userUID else { return nil }

        return BookMarkModel(userUid: userUID)
    }

    static func toModels(_ entities: Set<BookmarkEntity>?) -> [BookMarkModel] {
        guard let entities = entities else { return [] }

        return entities.compactMap { toModel($0) }
    }

    static func toEntity(_ model: BookMarkModel, context: NSManagedObjectContext) -> BookmarkEntity {
        let entity = BookmarkEntity(context: context)
        entity.userUID = model.userUid
        return entity
    }
}

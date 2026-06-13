//
//  ReviewEntityMapper.swift
//  HiRoute
//
//  Created by Jupond on 1/21/26.
//

import Foundation
import CoreData

struct ReviewEntityMapper {
    static func toModel(_ entity: ReviewEntity?) -> ReviewModel? {
        guard let entity = entity,
              let reviewUID = entity.reviewUID else { return nil }

        // ReviewImageEntity -> ImageModel 변환
        let images: [ImageModel]
        if let imageSet = entity.images as? Set<ReviewImageEntity> {
            images = imageSet.compactMap { imageEntity in
                guard let id = imageEntity.uid,
                      let imageUrl = imageEntity.imageURL else { return nil }

                return ImageModel(
                    id: id,
                    userUid: imageEntity.userUID,
                    imageUrl: imageUrl,
                    isAiGenerated: imageEntity.isAIGenerated,
                    createdAt: imageEntity.date.map { ISO8601DateFormatter().string(from: $0) }
                )
            }
        } else {
            images = []
        }

        // UsefulEntity -> UsefulModel 변환
        let usefulList: [UsefulModel]
        if let usefulSet = entity.usefulList as? Set<UsefulEntity> {
            usefulList = usefulSet.compactMap { usefulEntity in
                guard let userUID = usefulEntity.userUID else { return nil }
                return UsefulModel(userUid: userUID)
            }
        } else {
            usefulList = []
        }

        return ReviewModel(
            reviewUid: reviewUID,
            reviewText: entity.reviewText,
            userUid: entity.userUID ?? "",
            userName: entity.userName ?? "",
            visitDate: entity.visitDate.map { ISO8601DateFormatter().string(from: $0) },
            rating: Int(entity.rating),
            usefulCount: Int(entity.usefulCount),
            images: images,
            usefulList: usefulList
        )
    }

    static func toModels(_ entities: Set<ReviewEntity>?) -> [ReviewModel] {
        guard let entities = entities else { return [] }

        return entities.compactMap { toModel($0) }
    }

    static func toEntity(_ model: ReviewModel, context: NSManagedObjectContext) -> ReviewEntity {
        let entity = ReviewEntity(context: context)
        entity.reviewUID = model.reviewUid
        entity.reviewText = model.reviewText
        entity.userUID = model.userUid
        entity.userName = model.userName
        entity.visitDate = model.visitDateAsDate
        entity.rating = Int32(model.rating)
        entity.usefulCount = Int32(model.usefulCount)

        // ImageModel -> ReviewImageEntity 생성
        for image in model.images {
            let imageEntity = ReviewImageEntity(context: context)
            imageEntity.uid = image.id
            imageEntity.userUID = image.userUid
            imageEntity.date = image.createdAt.flatMap { str in
                let iso = ISO8601DateFormatter()
                return iso.date(from: str)
            }
            imageEntity.imageURL = image.imageUrl
            imageEntity.isAIGenerated = image.isAiGenerated
            imageEntity.review = entity
            entity.addToImages(imageEntity)
        }

        // UsefulModel -> UsefulEntity 생성
        for useful in (model.usefulList ?? []) {
            let usefulEntity = UsefulEntity(context: context)
            usefulEntity.userUID = useful.userUid
            usefulEntity.review = entity
            entity.addToUsefulList(usefulEntity)
        }

        return entity
    }
}

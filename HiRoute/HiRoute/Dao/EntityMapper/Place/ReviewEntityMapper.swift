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
        
        // ReviewImageEntity -> ReviewImageModel 변환
        let images: [ReviewImageModel]
        if let imageSet = entity.images as? Set<ReviewImageEntity> {
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
        if let usefulSet = entity.usefulList as? Set<UsefulEntity> {
            usefulList = usefulSet.compactMap { usefulEntity in
                guard let userUID = usefulEntity.userUID else { return nil }
                return UsefulModel(userUID: userUID)
            }
        } else {
            usefulList = []
        }
        
        return ReviewModel(
            reviewUID: reviewUID,
            reviewText: entity.reviewText ?? "",
            userUID: entity.userUID ?? "",
            userName: entity.userName ?? "",
            visitDate: entity.visitDate ?? Date(),
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
        entity.reviewUID = model.reviewUID
        entity.reviewText = model.reviewText
        entity.userUID = model.userUID
        entity.userName = model.userName
        entity.visitDate = model.visitDate
        entity.usefulCount = Int32(model.usefulCount)
        
        // ReviewImageModel -> ReviewImageEntity 생성
        for image in model.images {
            let imageEntity = ReviewImageEntity(context: context)
            imageEntity.uid = image.uid
            imageEntity.userUID = image.userUID
            imageEntity.date = image.date
            imageEntity.imageURL = image.imageURL
            imageEntity.review = entity
            entity.addToImages(imageEntity)
        }
        
        // UsefulModel -> UsefulEntity 생성
        for useful in model.usefulList {
            let usefulEntity = UsefulEntity(context: context)
            usefulEntity.userUID = useful.userUID
            usefulEntity.review = entity
            entity.addToUsefulList(usefulEntity)
        }
        
        return entity
    }
}

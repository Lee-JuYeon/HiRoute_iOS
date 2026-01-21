//
//  PlaceEntityMapper.swift
//  HiRoute
//
//  Created by Jupond on 1/21/26.
//

import CoreData

// MARK: - PlaceEntityMapper (전체 데이터 항상 포함)
struct PlaceEntityMapper {
    static func toModel(_ entity: PlaceEntity?, fullData: Bool = true) -> PlaceModel? {
        guard let entity = entity,
              let uid = entity.uid,
              let title = entity.title else { return nil }
        
        // 주소 변환 (첫 번째 주소만)
        let addressModel: AddressModel
        if let addressSet = entity.address as? Set<AddressEntity>,
           let firstAddress = addressSet.first {
            addressModel = AddressEntityMapper.toModel(firstAddress) ?? AddressModel.empty()
        } else {
            addressModel = AddressModel.empty()
        }
        
        // ⏰ WorkingTimeEntity -> WorkingTimeModel 변환
        let workingTimes = WorkingTimeEntityMapper.toModels(entity.workingTimes as? Set<WorkingTimeEntity>)
        
        // 📝 ReviewEntity -> ReviewModel 변환
        let reviews = ReviewEntityMapper.toModels(entity.reviews as? Set<ReviewEntity>)
        
        // 🔖 BookmarkEntity -> BookMarkModel 변환
        let bookMarks = BookmarkEntityMapper.toModels(entity.bookMarks as? Set<BookmarkEntity>)
        
        // ⭐ StarEntity -> StarModel 변환
        let stars = StarEntityMapper.toModels(entity.stars as? Set<StarEntity>)
        
        return PlaceModel(
            uid: uid,
            address: addressModel,
            type: PlaceType(rawValue: entity.type ?? "") ?? .restaurant,
            title: title,
            subtitle: entity.subtitle,
            thumbnailImageURL: entity.thumbnailImageURL,
            workingTimes: workingTimes, // ✅ 항상 전체 데이터
            reviews: reviews,           // ✅ 항상 전체 데이터
            bookMarks: bookMarks,      // ✅ 항상 전체 데이터
            stars: stars               // ✅ 항상 전체 데이터
        )
    }
    
    static func toModels(_ entities: Set<PlaceEntity>?, fullData: Bool = true) -> [PlaceModel] {
        guard let entities = entities else { return [] }
        
        return entities.compactMap { toModel($0, fullData: fullData) }
    }
    
    static func toEntity(_ model: PlaceModel, context: NSManagedObjectContext) -> PlaceEntity {
        let entity = PlaceEntity(context: context)
        entity.uid = model.uid
        entity.title = model.title
        entity.subtitle = model.subtitle
        entity.thumbnailImageURL = model.thumbnailImageURL
        entity.type = model.type.rawValue
        
        // 주소 생성
        let addressEntity = AddressEntityMapper.toEntity(model.address, context: context)
        addressEntity.place = entity
        entity.addToAddress(addressEntity)
        
        // WorkingTime 생성
        for workingTime in model.workingTimes {
            let workingTimeEntity = WorkingTimeEntityMapper.toEntity(workingTime, context: context)
            workingTimeEntity.place = entity
            entity.addToWorkingTimes(workingTimeEntity)
        }
        
        // Review 생성
        for review in model.reviews {
            let reviewEntity = ReviewEntityMapper.toEntity(review, context: context)
            reviewEntity.place = entity
            entity.addToReviews(reviewEntity)
        }
        
        // Bookmark 생성
        for bookmark in model.bookMarks {
            let bookmarkEntity = BookmarkEntityMapper.toEntity(bookmark, context: context)
            bookmarkEntity.place = entity
            entity.addToBookMarks(bookmarkEntity)
        }
        
        // Star 생성
        for star in model.stars {
            let starEntity = StarEntityMapper.toEntity(star, context: context)
            starEntity.place = entity
            entity.addToStars(starEntity)
        }
        
        return entity
    }
}

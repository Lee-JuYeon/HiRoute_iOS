//
//  AddressEntityMapper.swift
//  HiRoute
//
//  Created by Jupond on 1/21/26.
//

import CoreData

struct AddressEntityMapper {
    static func toModel(_ entity: AddressEntity?) -> AddressModel? {
        guard let entity = entity else { return nil }
        
        return AddressModel(
            uid: entity.addressUID ?? "",
            lat: entity.addressLat,
            lon: entity.addressLon,
            addressTitle: entity.addressTitle ?? "",
            addressBlock1: entity.sido ?? "",
            addressBlock2: entity.gungu ?? "",
            addressBlock3: entity.dong ?? "",
            fullAddress: entity.fullAddress ?? ""
        )
    }
    
    static func toModels(_ entities: Set<AddressEntity>?) -> [AddressModel] {
        guard let entities = entities else { return [] }
        
        return entities.compactMap { toModel($0) }
    }
    
    static func toEntity(_ model: AddressModel, context: NSManagedObjectContext) -> AddressEntity {
        let entity = AddressEntity(context: context)
        entity.addressUID = model.uid
        entity.addressLat = model.lat
        entity.addressLon = model.lon
        entity.addressTitle = model.addressTitle
        entity.sido = model.addressBlock1
        entity.gungu = model.addressBlock2
        entity.dong = model.addressBlock3
        entity.fullAddress = model.fullAddress
        return entity
    }
}

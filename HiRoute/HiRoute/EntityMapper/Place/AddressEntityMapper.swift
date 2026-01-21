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
            addressUID: entity.addressUID ?? "",
            addressLat: entity.addressLat,
            addressLon: entity.addressLon,
            addressTitle: entity.addressTitle ?? "",
            sido: entity.sido ?? "",
            gungu: entity.gungu ?? "",
            dong: entity.dong ?? "",
            fullAddress: entity.fullAddress ?? ""
        )
    }
    
    static func toModels(_ entities: Set<AddressEntity>?) -> [AddressModel] {
        guard let entities = entities else { return [] }
        
        return entities.compactMap { toModel($0) }
    }
    
    static func toEntity(_ model: AddressModel, context: NSManagedObjectContext) -> AddressEntity {
        let entity = AddressEntity(context: context)
        entity.addressUID = model.addressUID
        entity.addressLat = model.addressLat
        entity.addressLon = model.addressLon
        entity.addressTitle = model.addressTitle
        entity.sido = model.sido
        entity.gungu = model.gungu
        entity.dong = model.dong
        entity.fullAddress = model.fullAddress
        return entity
    }
}

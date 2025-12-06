//
//  AddressEntity+CoreDataProperties.swift
//  HiRoute
//
//  Created by Jupond on 12/6/25.
//
//

import Foundation
import CoreData


extension AddressEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AddressEntity> {
        return NSFetchRequest<AddressEntity>(entityName: "AddressEntity")
    }

    @NSManaged public var addressLat: Double
    @NSManaged public var addressLon: Double
    @NSManaged public var addressTitle: String?
    @NSManaged public var addressUID: String?
    @NSManaged public var dong: String?
    @NSManaged public var fullAddress: String?
    @NSManaged public var gungu: String?
    @NSManaged public var sido: String?
    @NSManaged public var place: PlaceEntity?

}

extension AddressEntity : Identifiable {

}

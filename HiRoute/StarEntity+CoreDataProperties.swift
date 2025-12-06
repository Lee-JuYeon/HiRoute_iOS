//
//  StarEntity+CoreDataProperties.swift
//  HiRoute
//
//  Created by Jupond on 12/6/25.
//
//

import Foundation
import CoreData


extension StarEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StarEntity> {
        return NSFetchRequest<StarEntity>(entityName: "StarEntity")
    }

    @NSManaged public var star: Int32
    @NSManaged public var userUID: String?
    @NSManaged public var place: PlaceEntity?

}

extension StarEntity : Identifiable {

}

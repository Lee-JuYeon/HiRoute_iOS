//
//  WorkingTimeEntity+CoreDataProperties.swift
//  HiRoute
//
//  Created by Jupond on 12/6/25.
//
//

import Foundation
import CoreData


extension WorkingTimeEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkingTimeEntity> {
        return NSFetchRequest<WorkingTimeEntity>(entityName: "WorkingTimeEntity")
    }

    @NSManaged public var close: String?
    @NSManaged public var dayTitle: String?
    @NSManaged public var id: String?
    @NSManaged public var lastOrder: String?
    @NSManaged public var open: String?
    @NSManaged public var place: PlaceEntity?

}

extension WorkingTimeEntity : Identifiable {

}

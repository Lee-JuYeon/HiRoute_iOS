//
//  UsefulEntity+CoreDataProperties.swift
//  HiRoute
//
//  Created by Jupond on 12/6/25.
//
//

import Foundation
import CoreData


extension UsefulEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UsefulEntity> {
        return NSFetchRequest<UsefulEntity>(entityName: "UsefulEntity")
    }

    @NSManaged public var userUID: String?
    @NSManaged public var review: ReviewEntity?

}

extension UsefulEntity : Identifiable {

}

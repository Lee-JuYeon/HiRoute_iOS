//
//  ReviewImageEntity+CoreDataProperties.swift
//  HiRoute
//
//  Created by Jupond on 12/6/25.
//
//

import Foundation
import CoreData


extension ReviewImageEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReviewImageEntity> {
        return NSFetchRequest<ReviewImageEntity>(entityName: "ReviewImageEntity")
    }

    @NSManaged public var date: Date?
    @NSManaged public var imageURL: String?
    @NSManaged public var uid: String?
    @NSManaged public var userUID: String?
    @NSManaged public var review: ReviewEntity?

}

extension ReviewImageEntity : Identifiable {

}

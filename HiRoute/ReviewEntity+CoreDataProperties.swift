//
//  ReviewEntity+CoreDataProperties.swift
//  HiRoute
//
//  Created by Jupond on 12/6/25.
//
//

import Foundation
import CoreData


extension ReviewEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReviewEntity> {
        return NSFetchRequest<ReviewEntity>(entityName: "ReviewEntity")
    }

    @NSManaged public var reviewText: String?
    @NSManaged public var reviewUID: String?
    @NSManaged public var usefulCount: Int32
    @NSManaged public var userName: String?
    @NSManaged public var userUID: String?
    @NSManaged public var visitDate: Date?
    @NSManaged public var images: NSSet?
    @NSManaged public var place: PlaceEntity?
    @NSManaged public var usefulList: NSSet?

}

// MARK: Generated accessors for images
extension ReviewEntity {

    @objc(addImagesObject:)
    @NSManaged public func addToImages(_ value: ReviewImageEntity)

    @objc(removeImagesObject:)
    @NSManaged public func removeFromImages(_ value: ReviewImageEntity)

    @objc(addImages:)
    @NSManaged public func addToImages(_ values: NSSet)

    @objc(removeImages:)
    @NSManaged public func removeFromImages(_ values: NSSet)

}

// MARK: Generated accessors for usefulList
extension ReviewEntity {

    @objc(addUsefulListObject:)
    @NSManaged public func addToUsefulList(_ value: UsefulEntity)

    @objc(removeUsefulListObject:)
    @NSManaged public func removeFromUsefulList(_ value: UsefulEntity)

    @objc(addUsefulList:)
    @NSManaged public func addToUsefulList(_ values: NSSet)

    @objc(removeUsefulList:)
    @NSManaged public func removeFromUsefulList(_ values: NSSet)

}

extension ReviewEntity : Identifiable {

}

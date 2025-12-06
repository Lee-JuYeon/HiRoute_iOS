//
//  PlaceEntity+CoreDataProperties.swift
//  HiRoute
//
//  Created by Jupond on 12/6/25.
//
//

import Foundation
import CoreData


extension PlaceEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlaceEntity> {
        return NSFetchRequest<PlaceEntity>(entityName: "PlaceEntity")
    }

    @NSManaged public var subtitle: String?
    @NSManaged public var thumbnailImageURL: String?
    @NSManaged public var title: String?
    @NSManaged public var type: String?
    @NSManaged public var uid: String?
    @NSManaged public var address: NSSet?
    @NSManaged public var bookMarks: NSSet?
    @NSManaged public var reviews: NSSet?
    @NSManaged public var stars: NSSet?
    @NSManaged public var workingTimes: NSSet?

}

// MARK: Generated accessors for address
extension PlaceEntity {

    @objc(addAddressObject:)
    @NSManaged public func addToAddress(_ value: AddressEntity)

    @objc(removeAddressObject:)
    @NSManaged public func removeFromAddress(_ value: AddressEntity)

    @objc(addAddress:)
    @NSManaged public func addToAddress(_ values: NSSet)

    @objc(removeAddress:)
    @NSManaged public func removeFromAddress(_ values: NSSet)

}

// MARK: Generated accessors for bookMarks
extension PlaceEntity {

    @objc(addBookMarksObject:)
    @NSManaged public func addToBookMarks(_ value: BookmarkEntity)

    @objc(removeBookMarksObject:)
    @NSManaged public func removeFromBookMarks(_ value: BookmarkEntity)

    @objc(addBookMarks:)
    @NSManaged public func addToBookMarks(_ values: NSSet)

    @objc(removeBookMarks:)
    @NSManaged public func removeFromBookMarks(_ values: NSSet)

}

// MARK: Generated accessors for reviews
extension PlaceEntity {

    @objc(addReviewsObject:)
    @NSManaged public func addToReviews(_ value: ReviewEntity)

    @objc(removeReviewsObject:)
    @NSManaged public func removeFromReviews(_ value: ReviewEntity)

    @objc(addReviews:)
    @NSManaged public func addToReviews(_ values: NSSet)

    @objc(removeReviews:)
    @NSManaged public func removeFromReviews(_ values: NSSet)

}

// MARK: Generated accessors for stars
extension PlaceEntity {

    @objc(addStarsObject:)
    @NSManaged public func addToStars(_ value: StarEntity)

    @objc(removeStarsObject:)
    @NSManaged public func removeFromStars(_ value: StarEntity)

    @objc(addStars:)
    @NSManaged public func addToStars(_ values: NSSet)

    @objc(removeStars:)
    @NSManaged public func removeFromStars(_ values: NSSet)

}

// MARK: Generated accessors for workingTimes
extension PlaceEntity {

    @objc(addWorkingTimesObject:)
    @NSManaged public func addToWorkingTimes(_ value: WorkingTimeEntity)

    @objc(removeWorkingTimesObject:)
    @NSManaged public func removeFromWorkingTimes(_ value: WorkingTimeEntity)

    @objc(addWorkingTimes:)
    @NSManaged public func addToWorkingTimes(_ values: NSSet)

    @objc(removeWorkingTimes:)
    @NSManaged public func removeFromWorkingTimes(_ values: NSSet)

}

extension PlaceEntity : Identifiable {

}

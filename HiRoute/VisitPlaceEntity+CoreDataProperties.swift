//
//  VisitPlaceEntity+CoreDataProperties.swift
//  HiRoute
//
//  Created by Jupond on 12/6/25.
//
//

import Foundation
import CoreData


extension VisitPlaceEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VisitPlaceEntity> {
        return NSFetchRequest<VisitPlaceEntity>(entityName: "VisitPlaceEntity")
    }

    @NSManaged public var index: Int32
    @NSManaged public var memo: String?
    @NSManaged public var uid: String?
    @NSManaged public var files: NSSet?
    @NSManaged public var placeModel: PlaceEntity?
    @NSManaged public var schedule: ScheduleEntity?

}

// MARK: Generated accessors for files
extension VisitPlaceEntity {

    @objc(addFilesObject:)
    @NSManaged public func addToFiles(_ value: FileEntity)

    @objc(removeFilesObject:)
    @NSManaged public func removeFromFiles(_ value: FileEntity)

    @objc(addFiles:)
    @NSManaged public func addToFiles(_ values: NSSet)

    @objc(removeFiles:)
    @NSManaged public func removeFromFiles(_ values: NSSet)

}

extension VisitPlaceEntity : Identifiable {

}

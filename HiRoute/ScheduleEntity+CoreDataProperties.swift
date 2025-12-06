//
//  ScheduleEntity+CoreDataProperties.swift
//  HiRoute
//
//  Created by Jupond on 12/6/25.
//
//

import Foundation
import CoreData


extension ScheduleEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ScheduleEntity> {
        return NSFetchRequest<ScheduleEntity>(entityName: "ScheduleEntity")
    }

    @NSManaged public var d_day: Date?
    @NSManaged public var editDate: Date?
    @NSManaged public var index: Int32
    @NSManaged public var memo: String?
    @NSManaged public var title: String?
    @NSManaged public var uid: String?
    @NSManaged public var visitPlaceList: NSSet?

}

// MARK: Generated accessors for visitPlaceList
extension ScheduleEntity {

    @objc(addVisitPlaceListObject:)
    @NSManaged public func addToVisitPlaceList(_ value: VisitPlaceEntity)

    @objc(removeVisitPlaceListObject:)
    @NSManaged public func removeFromVisitPlaceList(_ value: VisitPlaceEntity)

    @objc(addVisitPlaceList:)
    @NSManaged public func addToVisitPlaceList(_ values: NSSet)

    @objc(removeVisitPlaceList:)
    @NSManaged public func removeFromVisitPlaceList(_ values: NSSet)

}

extension ScheduleEntity : Identifiable {

}

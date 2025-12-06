//
//  InfoEditRequestEntity+CoreDataProperties.swift
//  HiRoute
//
//  Created by Jupond on 12/6/25.
//
//

import Foundation
import CoreData


extension InfoEditRequestEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InfoEditRequestEntity> {
        return NSFetchRequest<InfoEditRequestEntity>(entityName: "InfoEditRequestEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var placeUID: String?
    @NSManaged public var requestDate: Date?
    @NSManaged public var requestText: String?
    @NSManaged public var userUID: String?

}

extension InfoEditRequestEntity : Identifiable {

}

//
//  FileEntity+CoreDataProperties.swift
//  HiRoute
//
//  Created by Jupond on 12/6/25.
//
//

import Foundation
import CoreData


extension FileEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FileEntity> {
        return NSFetchRequest<FileEntity>(entityName: "FileEntity")
    }

    @NSManaged public var createDate: Date?
    @NSManaged public var fileName: String?
    @NSManaged public var filePath: String?
    @NSManaged public var fileSize: Int64
    @NSManaged public var fileType: String?
    @NSManaged public var id: String?
    @NSManaged public var visitPlace: VisitPlaceEntity?

}

extension FileEntity : Identifiable {

}

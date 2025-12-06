//
//  CoreDataStack.swift
//  HiRoute
//
//  Created by Jupond on 12/6/25.
//
import CoreData
import Foundation

class CoreDataStack {
    static let shared = CoreDataStack()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Schedule") // Schedule.xcdatamodeld 파일명과 일치해야 함
        container.loadPersistentStores { _, error in
            if let error = error {
                print("❌ CoreData 로드 실패: \(error)")
            } else {
                print("✅ CoreData 로드 성공")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
                print("💾 CoreData 저장 완료")
            } catch {
                print("❌ CoreData 저장 실패: \(error)")
            }
        }
    }
}

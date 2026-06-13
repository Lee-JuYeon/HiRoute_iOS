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

        // NSFileProtection: 부팅 후 최초 잠금해제 전까지 DB 파일 암호화
        if let description = container.persistentStoreDescriptions.first {
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
            description.setOption(
                FileProtectionType.completeUntilFirstUserAuthentication as NSObject,
                forKey: NSPersistentStoreFileProtectionKey
            )
        }

        container.loadPersistentStores { [unowned container] storeDescription, error in
            if let error = error {
                print("❌ CoreData 로드 실패: \(error.localizedDescription)")
                // [2026-05-26] schema 변경 시 lightweight migration이 자동 inference에 실패하는 경우 대비.
                // 정식 해결은 .xcdatamodeld 버전 컨테이너 도입 — 다음 스프린트에 작업.
                // dev 단계에선 store destroy + 재생성으로 우회 (로컬 데이터 1회 손실).
                Self.destroyAndReload(container: container, storeDescription: storeDescription)
            } else {
                print("✅ CoreData 로드 성공")
            }
        }
        return container
    }()

    /// 마이그레이션 실패 시 store 파일을 destroy하고 한 번 더 load.
    /// dev 단계 임시 안전망. prod 출시 전에는 .xcdatamodeld 버전 도입으로 교체할 것.
    private static func destroyAndReload(container: NSPersistentContainer, storeDescription: NSPersistentStoreDescription) {
        guard let url = storeDescription.url else {
            print("❌ CoreData 재시도 실패: store URL 없음")
            return
        }
        do {
            try container.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType, options: nil)
            // 동반 파일도 정리 (WAL, SHM, journal)
            for suffix in ["-wal", "-shm", "-journal"] {
                let companion = url.appendingPathExtension(String(suffix.dropFirst()))
                try? FileManager.default.removeItem(at: companion)
            }
            try FileManager.default.removeItem(at: url)
            print("🔁 CoreData store 재생성 시도 — 기존 로컬 데이터 손실됨")
            container.loadPersistentStores { _, retryError in
                if let retryError = retryError {
                    print("❌ CoreData 재시도 실패: \(retryError.localizedDescription)")
                } else {
                    print("✅ CoreData 재생성 후 로드 성공")
                }
            }
        } catch {
            print("❌ store destroy 실패: \(error.localizedDescription)")
        }
    }
    
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

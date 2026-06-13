//
//  QuestAssetDAO.swift
//  HiRoute
//
//  Created by Codex on 5/8/26.
//

import CoreData
import Foundation

/// 퀘스트 리소스 메타데이터 CoreData CRUD.
struct QuestAssetDAO {
    private init() {}

    static func upsert(_ model: QuestAssetDTO, context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform {
            do {
                if let entity = try fetchEntity(assetId: model.assetId, context: context) {
                    QuestAssetEntityMapper.update(entity, with: model)
                } else {
                    _ = QuestAssetEntityMapper.toEntity(model, context: context)
                }

                try context.save()
                completion(true)
                print("QuestAssetDAO, upsert // Success : 퀘스트 리소스 저장 완료 - \(model.assetId)")
            } catch {
                completion(false)
                print("QuestAssetDAO, upsert // Exception : \(error.localizedDescription)")
            }
        }
    }

    static func read(assetId: String, context: NSManagedObjectContext, completion: @escaping (QuestAssetDTO?) -> Void) {
        context.perform {
            do {
                let entity = try fetchEntity(assetId: assetId, context: context)
                completion(QuestAssetEntityMapper.toModel(entity))
            } catch {
                print("QuestAssetDAO, read // Exception : \(error.localizedDescription)")
                completion(nil)
            }
        }
    }

    static func readAll(questId: String, context: NSManagedObjectContext, completion: @escaping ([QuestAssetDTO]) -> Void) {
        context.perform {
            do {
                let request: NSFetchRequest<QuestAssetEntity> = QuestAssetEntity.fetchRequest()
                request.predicate = NSPredicate(format: "questId == %@", questId)
                request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]

                let entities = try context.fetch(request)
                completion(QuestAssetEntityMapper.toModels(entities))
            } catch {
                print("QuestAssetDAO, readAll // Exception : \(error.localizedDescription)")
                completion([])
            }
        }
    }

    static func delete(assetId: String, context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform {
            do {
                guard let entity = try fetchEntity(assetId: assetId, context: context) else {
                    completion(true)
                    return
                }

                context.delete(entity)
                try context.save()
                completion(true)
                print("QuestAssetDAO, delete // Success : 퀘스트 리소스 삭제 완료 - \(assetId)")
            } catch {
                completion(false)
                print("QuestAssetDAO, delete // Exception : \(error.localizedDescription)")
            }
        }
    }

    private static func fetchEntity(assetId: String, context: NSManagedObjectContext) throws -> QuestAssetEntity? {
        let request: NSFetchRequest<QuestAssetEntity> = QuestAssetEntity.fetchRequest()
        request.predicate = NSPredicate(format: "assetId == %@", assetId)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}

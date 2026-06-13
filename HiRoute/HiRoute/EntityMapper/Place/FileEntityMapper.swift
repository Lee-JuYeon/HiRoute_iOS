//
//  FileEntityMapper.swift
//  HiRoute
//
//  Created by Jupond on 1/21/26.
//

import CoreData
import Foundation

// MARK: - FileEntityMapper
struct FileEntityMapper {
    static func toModel(_ entity: FileEntity?) -> FileModel? {
        guard let entity = entity,
              let id = entity.id,
              let fileName = entity.fileName else { return nil }
        
        return FileModel(
            id: UUID(uuidString: id) ?? UUID(),
            data: nil, // Entity에서는 실제 파일 데이터를 저장하지 않음
            fileName: fileName,
            fileType: entity.fileType ?? "",
            fileSize: entity.fileSize,
            filePath: entity.filePath ?? "",
            createdDate: entity.createdDate ?? Date(),
            isAiGenerated: entity.isAIGenerated
        )
    }
    
    /// [2026-05-26 Phase 3] 활성 파일만 반환 (soft-deleted 제외).
    static func toModels(_ entities: Set<FileEntity>?) -> [FileModel] {
        guard let entities = entities else { return [] }

        return entities
            .filter { $0.deletedAt == nil }
            .compactMap { toModel($0) }
            .sorted { $0.createdDate < $1.createdDate } // 생성일순 정렬
    }
    
    static func toEntity(_ model: FileModel, context: NSManagedObjectContext) -> FileEntity {
        let entity = FileEntity(context: context)
        entity.id = model.id.uuidString
        entity.fileName = model.fileName
        entity.fileType = model.fileType
        entity.fileSize = model.fileSize
        entity.filePath = model.filePath
        entity.createdDate = model.createdDate
        entity.isAIGenerated = model.isAiGenerated
        return entity
    }
    
    // 🔄 여러 FileModel들을 FileEntity들로 변환하여 Plan에 연결
    static func toEntitiesForPlan(_ models: [FileModel], planEntity: PlanEntity, context: NSManagedObjectContext) -> [FileEntity] {
        return models.map { model in
            let entity = toEntity(model, context: context)
            entity.visitPlace = planEntity // Plan과 연결
            return entity
        }
    }
}

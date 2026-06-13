//
//  QuestAssetEntityMapper.swift
//  HiRoute
//
//  Created by Codex on 5/8/26.
//

import CoreData
import Foundation

/// CoreData Entity와 앱에서 쓰는 DTO를 서로 변환한다.
struct QuestAssetEntityMapper {
    static func toModel(_ entity: QuestAssetEntity?) -> QuestAssetDTO? {
        guard let entity,
              let assetId = entity.assetId,
              let questId = entity.questId,
              let name = entity.name,
              let assetTypeRawValue = entity.assetType,
              let assetType = QuestAssetType(rawValue: assetTypeRawValue),
              let remoteURL = entity.remoteURL else { return nil }

        return QuestAssetDTO(
            assetId: assetId,
            questId: questId,
            name: name,
            assetType: assetType,
            remoteURL: remoteURL,
            localRelativePath: entity.localRelativePath,
            fileHash: entity.fileHash,
            fileSize: entity.fileSize,
            mimeType: entity.mimeType,
            duration: entity.duration,
            latitude: entity.latitude,
            longitude: entity.longitude,
            altitude: entity.altitude,
            animationName: entity.animationName,
            isDownloaded: entity.isDownloaded,
            downloadedAt: entity.downloadedAt,
            updatedAt: entity.updatedAt ?? Date()
        )
    }

    static func toModels(_ entities: [QuestAssetEntity]) -> [QuestAssetDTO] {
        entities.compactMap { toModel($0) }
    }

    static func toEntity(_ model: QuestAssetDTO, context: NSManagedObjectContext) -> QuestAssetEntity {
        let entity = QuestAssetEntity(context: context)
        update(entity, with: model)
        return entity
    }

    static func update(_ entity: QuestAssetEntity, with model: QuestAssetDTO) {
        entity.assetId = model.assetId
        entity.questId = model.questId
        entity.name = model.name
        entity.assetType = model.assetType.rawValue
        entity.remoteURL = model.remoteURL
        entity.localRelativePath = model.localRelativePath
        entity.fileHash = model.fileHash
        entity.fileSize = model.fileSize
        entity.mimeType = model.mimeType
        entity.duration = model.duration ?? 0
        entity.latitude = model.latitude
        entity.longitude = model.longitude
        entity.altitude = model.altitude
        entity.animationName = model.animationName
        entity.isDownloaded = model.isDownloaded
        entity.downloadedAt = model.downloadedAt
        entity.updatedAt = model.updatedAt
    }
}

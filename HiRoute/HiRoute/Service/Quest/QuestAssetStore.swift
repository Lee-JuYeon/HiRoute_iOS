//
//  QuestAssetStore.swift
//  HiRoute
//
//  Created by Codex on 5/8/26.
//

import Foundation

/// 퀘스트 리소스 파일 저장과 CoreData 메타데이터 저장을 한 번에 묶어서 다루는 진입점.
/// 화면/퀘스트 로직은 이 Store만 호출하면 파일 위치와 DB 저장 방식을 몰라도 된다.
final class QuestAssetStore {
    static let shared = QuestAssetStore()

    private let localDB = LocalDB.shared
    private let applicationSupportManager = ApplicationSupportManager.shared

    private init() {}

    func upsertMetadata(_ model: QuestAssetDTO, completion: @escaping (Bool) -> Void) {
        localDB.upsertQuestAsset(model, completion: completion)
    }

    func readAsset(assetId: String, completion: @escaping (QuestAssetDTO?) -> Void) {
        localDB.readQuestAsset(assetId: assetId, completion: completion)
    }

    func readAssets(questId: String, completion: @escaping ([QuestAssetDTO]) -> Void) {
        localDB.readQuestAssets(questId: questId, completion: completion)
    }

    /// 다운로드한 파일 Data를 Application Support에 저장하고, CoreData 메타데이터도 다운로드 완료 상태로 갱신한다.
    func saveDownloadedAsset(
        data: Data,
        asset: QuestAssetDTO,
        fileName: String? = nil,
        completion: @escaping (Result<QuestAssetDTO, Error>) -> Void
    ) {
        do {
            let resolvedFileName = fileName ?? defaultFileName(for: asset)
            let relativePath = try applicationSupportManager.saveQuestAsset(
                data: data,
                questId: asset.questId,
                assetType: asset.assetType,
                fileName: resolvedFileName
            )

            let downloadedAsset = QuestAssetDTO(
                assetId: asset.assetId,
                questId: asset.questId,
                name: asset.name,
                assetType: asset.assetType,
                remoteURL: asset.remoteURL,
                localRelativePath: relativePath,
                fileHash: asset.fileHash,
                fileSize: Int64(data.count),
                mimeType: asset.mimeType,
                duration: asset.duration,
                latitude: asset.latitude,
                longitude: asset.longitude,
                altitude: asset.altitude,
                animationName: asset.animationName,
                isDownloaded: true,
                downloadedAt: Date(),
                updatedAt: Date()
            )

            localDB.upsertQuestAsset(downloadedAsset) { success in
                success ? completion(.success(downloadedAsset)) : completion(.failure(QuestAssetStoreError.metadataSaveFailed))
            }
        } catch {
            completion(.failure(error))
        }
    }

    func localFileURL(for asset: QuestAssetDTO) -> URL? {
        guard applicationSupportManager.fileExists(relativePath: asset.localRelativePath) else {
            return nil
        }
        return asset.localFileURL
    }

    /// 파일과 메타데이터를 함께 제거한다.
    func deleteAsset(_ asset: QuestAssetDTO, completion: @escaping (Bool) -> Void) {
        do {
            try applicationSupportManager.removeFile(relativePath: asset.localRelativePath)
            localDB.deleteQuestAsset(assetId: asset.assetId, completion: completion)
        } catch {
            print("QuestAssetStore, deleteAsset // Exception : \(error.localizedDescription)")
            completion(false)
        }
    }

    private func defaultFileName(for asset: QuestAssetDTO) -> String {
        switch asset.assetType {
        case .model3D: return "\(asset.assetId).usdz"
        case .audio: return "\(asset.assetId).m4a"
        case .image: return "\(asset.assetId).png"
        case .video: return "\(asset.assetId).mp4"
        }
    }
}

enum QuestAssetStoreError: Error {
    case metadataSaveFailed
}

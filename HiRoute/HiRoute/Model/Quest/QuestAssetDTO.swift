//
//  QuestAssetDTO.swift
//  HiRoute
//
//  Created by Codex on 5/8/26.
//

import Foundation

/// 퀘스트가 오프라인에서 사용할 리소스 타입이다.
/// 3D 모델, 오디오, 이미지, 영상 모두 같은 저장 흐름을 탄다.
enum QuestAssetType: String, Codable, Hashable {
    case model3D
    case audio
    case image
    case video

    var folderName: String {
        switch self {
        case .model3D: return "models"
        case .audio: return "audio"
        case .image: return "images"
        case .video: return "videos"
        }
    }
}

/// 오프라인 퀘스트에서 사용할 리소스 메타데이터.
/// 실제 파일은 Application Support에 저장하고, 이 DTO는 CoreData에 저장한다.
struct QuestAssetDTO: Codable, Identifiable, Hashable {
    var id: String { assetId }

    let assetId: String
    let questId: String
    let name: String
    let assetType: QuestAssetType

    let remoteURL: String
    let localRelativePath: String?

    let fileHash: String?
    let fileSize: Int64
    let mimeType: String?
    let duration: Double?

    let latitude: Double
    let longitude: Double
    let altitude: Double

    let animationName: String?
    let isDownloaded: Bool
    let downloadedAt: Date?
    let updatedAt: Date

    var localFileURL: URL? {
        guard let localRelativePath else { return nil }
        return ApplicationSupportManager.shared.absoluteURL(forRelativePath: localRelativePath)
    }
}

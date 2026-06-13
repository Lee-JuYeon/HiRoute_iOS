//
//  PlanFileResponse.swift
//  HiRoute
//
//  Created by Jupond on 5/5/26.
//

/// [2026-05-26 FIX] APIClient의 decoder는 `keyDecodingStrategy = .convertFromSnakeCase`라
/// 들어오는 키들이 이미 camelCase로 변환된 후 CodingKeys와 매칭됨.
/// 따라서 CodingKeys의 rawValue도 변환 후 camelCase 형태여야 함.
/// - 서버 `plan_uid` → 디코더 변환 → `planUid` (CodingKeys.planUid 매칭, 명시 매핑 불필요)
/// - 서버 `file_url` → 디코더 변환 → `fileUrl` (camelCase 다른 이름이라 명시 매핑 필요)
/// - `file_type` → `fileType`, `created_at` → `createdAt` 모두 자동 (생략 가능).
struct PlanFileResponse: Decodable {
    let uid: String
    let planUid: String
    let filePath: String
    let fileType: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case uid
        case planUid          // convertFromSnakeCase가 "plan_uid" → "planUid" 변환
        case filePath = "fileUrl"  // 서버 "file_url" → 변환 후 "fileUrl" → 명시 매핑
        case fileType
        case createdAt
    }
}

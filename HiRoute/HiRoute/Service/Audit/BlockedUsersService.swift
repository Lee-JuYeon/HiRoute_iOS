//
//  BlockedUsersService.swift
//  HiRoute
//
//  Created by Claude on 5/27/26.
//
//  [2026-05-27 Phase A.9] 사용자 차단 — Apple App Store §1.2 UGC 앱 필수.
//  WHY: 부적절한 리뷰 작성자를 사용자가 즉시 숨길 수 있어야 함. v1.0은 로컬 UserDefaults.
//  v1.1 계획: 서버 동기화 (다중 기기 + 차단된 사용자가 본인 리뷰 못 보내게).
//

import Foundation
import Combine

final class BlockedUsersService: ObservableObject {
    static let shared = BlockedUsersService()

    private let storageKey = "blockedUserUIDs"
    @Published private(set) var blockedUIDs: Set<String> = []

    private init() {
        load()
    }

    func isBlocked(_ userUID: String) -> Bool {
        blockedUIDs.contains(userUID)
    }

    /// 차단 — 차단된 user의 리뷰는 즉시 숨김.
    func block(_ userUID: String) {
        guard !userUID.isEmpty else { return }
        blockedUIDs.insert(userUID)
        save()
        #if DEBUG
        print("BlockedUsersService, block // \(userUID)")
        #endif
    }

    /// 차단 해제.
    func unblock(_ userUID: String) {
        blockedUIDs.remove(userUID)
        save()
    }

    /// 리뷰 list 필터 — 차단된 사용자 제외.
    func filterReviews(_ reviews: [ReviewModel]) -> [ReviewModel] {
        guard !blockedUIDs.isEmpty else { return reviews }
        return reviews.filter { !blockedUIDs.contains($0.userUid) }
    }

    // MARK: - Private

    private func load() {
        if let arr = UserDefaults.standard.array(forKey: storageKey) as? [String] {
            blockedUIDs = Set(arr)
        }
    }

    private func save() {
        UserDefaults.standard.set(Array(blockedUIDs), forKey: storageKey)
    }
}

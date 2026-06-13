//
//  ScheduleSyncRequest.swift
//  HiRoute
//
//  Created by Jupond on 5/5/26.
//

struct ScheduleSyncRequest: Encodable {
    let lastSyncAt: String
    let changes: ScheduleSyncChanges

    enum CodingKeys: String, CodingKey {
        case changes
        case lastSyncAt = "last_sync_at"
    }
}

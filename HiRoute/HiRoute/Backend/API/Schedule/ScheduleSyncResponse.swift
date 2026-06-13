//
//  ScheduleSyncResponse.swift
//  HiRoute
//
//  Created by Jupond on 5/5/26.
//

struct ScheduleSyncResponse: Decodable {
    let serverChanges: [ScheduleResponse]
    let deletedOnServer: [String]
    let syncAt: String
}

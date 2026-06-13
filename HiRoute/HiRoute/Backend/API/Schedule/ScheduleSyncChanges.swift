//
//  ScheduleSyncChanges.swift
//  HiRoute
//
//  Created by Jupond on 5/5/26.
//


struct ScheduleSyncChanges: Encodable {
    let created: [ScheduleCreateRequest]
    let updated: [ScheduleSyncUpdateItem]
    let deleted: [String]
}


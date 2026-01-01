//
//  OfflineQueueDelegate.swift
//  HiRoute
//
//  Created by Jupond on 12/5/25.
//

enum QueueOperation {
    case create(ScheduleModel)
    case update(ScheduleModel)
    case delete(String)
    case readAll           // 서버에서 전체 목록 가져오기
    case read(String)      // 서버에서 특정 일정 가져오기
}

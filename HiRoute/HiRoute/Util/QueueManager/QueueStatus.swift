//
//  ScheduleDeleteManager.swift
//  HiRoute
//
//  Created by Jupond on 12/5/25.
//
import Combine
import Foundation

enum QueueStatus {
    case pending
    case processing
    case success
    case failed(Error)
}


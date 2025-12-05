//
//  CacheWrapper.swift
//  HiRoute
//
//  Created by Jupond on 12/5/25.
//

import Foundation

class CacheWrapper: NSObject {
    let data: Any
    let priority: CachePriority
    let cost: Int
    let createdAt: Date
    let originalHash: String
    
    init<T: CacheableModel>(data: T, priority: CachePriority, cost: Int) {
        self.data = data
        self.priority = priority
        self.cost = cost
        self.createdAt = Date()
        self.originalHash = data.contentHash
        super.init()
    }
}

//
//  OfflineQueueDelegate.swift
//  HiRoute
//
//  Created by Jupond on 12/5/25.
//

protocol OfflineQueueDelegate: AnyObject {
    func addToQueue(_ operation: OfflineOperation)
}

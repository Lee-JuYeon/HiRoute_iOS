//
//  KeychainError.swift
//  HiRoute
//
//  Created by Jupond on 3/13/26.
//

import Darwin

// MARK: - Error
enum KeychainError: Error {
    case saveFailed(OSStatus)
    case itemNotFound
}

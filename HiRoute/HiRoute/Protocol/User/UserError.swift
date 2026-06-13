//
//  UserError.swift
//  HiRoute
//
//  Created by Jupond on 3/13/26.
//

enum UserError: Error {
    case saveFailed
    case notFound
    case duplicateUser
    case validationFailed(String)
    case unknown
}

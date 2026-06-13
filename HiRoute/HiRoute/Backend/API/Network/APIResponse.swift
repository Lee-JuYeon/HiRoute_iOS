//
//  APIResponse.swift
//  HiRoute
//
//  Created by Jupond on 3/10/26.
//
import Foundation

// MARK: - API Response Wrappers

struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T
    let meta: PaginationMeta?
}





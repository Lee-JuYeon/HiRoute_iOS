//
//  PaginationInfo.swift
//  HiRoute
//
//  Created by Jupond on 12/29/25.
//

// MARK: - PaginationInfo 구조체
struct PaginationInfo {
    let currentPage: Int
    let itemsPerPage: Int
    let totalItems: Int
    let totalPages: Int
    let hasNextPage: Bool
    let hasPreviousPage: Bool
}

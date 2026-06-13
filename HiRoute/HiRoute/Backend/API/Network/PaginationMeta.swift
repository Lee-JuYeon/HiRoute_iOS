//
//  PaginationMeta.swift
//  HiRoute
//
//  Created by Jupond on 3/13/26.
//

struct PaginationMeta: Decodable {
    let page: Int
    let limit: Int
    let total: Int
    let totalPages: Int
}

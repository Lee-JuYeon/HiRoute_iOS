//
//  VisitSeoulResponse.swift
//  HiRoute
//
//  Created by Jupond on 5/5/26.
//

struct VisitSeoulResponse<T: Decodable>: Decodable {
    let data: T
    let resultCode: Int
    let resultMessage: String
}

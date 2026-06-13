//
//  APIErrorResponse.swift
//  HiRoute
//
//  Created by Jupond on 3/13/26.
//


struct APIErrorResponse: Decodable {
    let success: Bool
    let error: APIErrorDetail
}

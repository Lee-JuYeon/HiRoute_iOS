//
//  RefreshResponse.swift
//  HiRoute
//
//  Created by Jupond on 3/11/26.
//

struct RefreshResponse : Decodable {
    let accessToken : String
    let refreshToken : String
}

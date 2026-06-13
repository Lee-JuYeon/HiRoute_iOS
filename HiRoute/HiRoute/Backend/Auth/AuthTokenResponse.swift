//
//  AuthTokenResponse.swift
//  HiRoute
//
//  Created by Jupond on 3/11/26.
//

struct AuthTokenResponse: Decodable {
    let user: AuthUser
    let accessToken: String
    let refreshToken: String
}

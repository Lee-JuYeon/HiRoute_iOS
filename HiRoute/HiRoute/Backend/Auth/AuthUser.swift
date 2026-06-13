//
//  AuthUser.swift
//  HiRoute
//
//  Created by Jupond on 3/11/26.
//

struct AuthUser: Decodable {
    let uid: String
    let name: String
    let nationality: String
    let gender: String
    let age: Int?
    let isNew: Bool
}

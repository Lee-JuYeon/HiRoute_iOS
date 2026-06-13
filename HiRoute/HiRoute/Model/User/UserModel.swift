//
//  UserModel.swift
//  HiRoute
//
//  Created by Jupond on 3/1/26.
//

import Foundation

struct UserModel: Codable, Identifiable {
    var id: String { uid }

    let uid: String
    let name: String
    let nationality: String
    let gender: GenderType
    let age: Int?
    let agreements: UserAgreementModel
    let createdDate: Date
    let editDate: Date
}

extension UserModel {
    static func empty() -> UserModel {
        return UserModel(
            uid: "",
            name: "",
            nationality: "JAPAN",
            gender: .male,
            age: nil,
            agreements: UserAgreementModel.empty(),
            createdDate: Date(),
            editDate: Date()
        )
    }
}

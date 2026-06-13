//
//  StarModel.swift
//  HiRoute
//
//  Created by Jupond on 11/21/25.
//


struct StarModel : Codable, Hashable, Identifiable {
    var id : String { userUid }
    var userUid : String
    var star : Int
}

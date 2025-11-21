//
//  ReviewImageModel.swift
//  HiRoute
//
//  Created by Jupond on 11/21/25.
//
import Foundation

struct ReviewImageModel : Hashable, Codable {
    var uid : String
    var userUID : String
    var date : Date
    var imageURL : String
}

//
//  ImageModel.swift
//  HiRoute
//
//  Created by Jupond on 11/21/25.
//
import Foundation

struct ImageModel : Hashable, Codable, Identifiable {
    var id : String
    var userUid : String? = nil
    var imageUrl : String
    var isAiGenerated : Bool = false
    var createdAt : String? = nil
}

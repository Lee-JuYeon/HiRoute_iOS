//
//  RouteModel.swift
//  HiRoute
//
//  Created by Jupond on 6/26/25.
//

import Foundation

struct InfoEditRequestModel : Codable {
    var id : String
    var userUid : String
    var placeUid : String
    var requestDate : Date
    var requestText : String
}

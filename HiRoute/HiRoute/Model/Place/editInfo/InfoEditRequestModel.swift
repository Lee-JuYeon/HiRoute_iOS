//
//  RouteModel.swift
//  HiRoute
//
//  Created by Jupond on 6/26/25.
//

import Foundation

struct InfoEditRequestModel : Codable {
    var id : String
    var userUID : String
    var placeUID : String
    var requestDate : Date
    var requestText : String
}

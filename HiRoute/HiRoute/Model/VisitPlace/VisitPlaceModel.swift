//
//  HomePlaceChip.swift
//  HiRoute
//
//  Created by Jupond on 7/17/25.
//

struct VisitPlaceModel : Codable, Identifiable {
    var id: String { uid }
    let uid : String
    let index : Int
    let memo : String
    let placeModel : PlaceModel
    let files : [String]
}

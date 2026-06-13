//
//  PlaceModel.swift
//  HiRoute
//
//  Created by Jupond on 6/26/25.
//
import Foundation

struct AddressModel : Hashable, Codable {
    let uid : String
    let lat : Double
    let lon : Double
    let addressTitle : String?
    let addressBlock1 : String?
    let addressBlock2 : String?
    let addressBlock3 : String?
    let fullAddress : String?

}

extension AddressModel {
    static func empty() -> AddressModel {
        return AddressModel(
            uid: "",
            lat: 0.0,
            lon: 0.0,
            addressTitle: "",
            addressBlock1: "",
            addressBlock2: "",
            addressBlock3: "",
            fullAddress: ""
        )
    }
}

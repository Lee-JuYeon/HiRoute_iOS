//
//  UsefulToggleResponse.swift
//  HiRoute
//

import Foundation

struct UsefulToggleResponse: Decodable {
    let toggled: Bool
    let usefulCount: Int
}

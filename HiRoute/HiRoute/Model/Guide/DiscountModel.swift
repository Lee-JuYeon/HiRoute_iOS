//
//  Discount.swift
//  HiRoute
//
//  Created by Jupond on 5/6/26.
//

struct DiscountModel: Codable, Hashable {
    let name: String
    let amount: Int
    var period: String?
}

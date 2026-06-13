//
//  PriceItem.swift
//  HiRoute
//
//  Created by Jupond on 5/6/26.
//

import Foundation

struct PriceModel: Codable, Identifiable, Hashable {
    var id: String { label }
    let label: String
    let basePrice: Int
    var discountPercent: Int?
    var discounts: [DiscountModel]?
    var notes: [String]?

    var totalPrice: Int {
        let discountTotal = discounts?.reduce(0) { $0 + $1.amount } ?? 0
        return max(0, basePrice + discountTotal)
    }

    private static let numberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        return f
    }()

    var displayPrice: String {
        totalPrice == 0 ? "무료" : "\(Self.numberFormatter.string(from: NSNumber(value: totalPrice)) ?? "\(totalPrice)")원"
    }

    var displayBasePrice: String {
        basePrice == 0 ? "무료" : "\(Self.numberFormatter.string(from: NSNumber(value: basePrice)) ?? "\(basePrice)")원"
    }
}

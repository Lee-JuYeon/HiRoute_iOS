//
//  DeleteAccountResponse.swift
//  HiRoute
//
//  Created by Claude on 5/27/26.
//
//  [2026-05-27 Phase A.6] DELETE /api/users/:uid 응답.
//

import Foundation

struct DeleteAccountResponse: Decodable {
    let message: String
    let gracePeriodDays: Int

    enum CodingKeys: String, CodingKey {
        case message
        case gracePeriodDays   // "grace_period_days" → convert → "gracePeriodDays"
    }
}

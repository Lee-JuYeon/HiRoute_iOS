//
//  VisitSeoulExtraDTO.swift
//  HiRoute
//
//  Created by Jupond on 5/5/26.
//

struct VisitSeoulExtraDTO: Decodable {
    let cmmnTelno: String?
    let cmmnHmpgUrl: String?
    let cmmnHmpgLang: [String]?
    let cmmnUseTime: String?
    let cmmnImportant: String?
    let trrsrtUseChrge: String?
    let trrsrtUseChrgeGuidance: String?
    let businessDays: String?
    let closedDays: String?
    let disabledFacility: [String]?
}

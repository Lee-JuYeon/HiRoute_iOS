//
//  VisitSeoulContentsListRequest.swift
//  HiRoute
//
//  Created by Jupond on 5/5/26.
//


struct VisitSeoulContentsListRequest: Encodable {
    let comCtgrySn: String?
    let langCodeId: String?
    let keyword: String?
    let sortType: String
    let pageNo: Int
}

//
//  VisitSeoulCategoryDTO.swift
//  HiRoute
//
//  Created by Jupond on 5/5/26.
//

struct VisitSeoulCategoryDTO: Decodable {
    let comCtgrySn: String
    let ctgryNm: String
    let ctgryPath: String
    let ctgryLevel: Int
    let sortNo: Int
}

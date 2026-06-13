//
//  VisitSeoulContentListDTO.swift
//  HiRoute
//
//  Created by Jupond on 5/5/26.
//

struct VisitSeoulContentListDTO: Decodable {
    let cid: String
    let langCodeId: String?
    let comCtgrySn: String?
    let cateDepth: VisitSeoulCategoryDepthValue?
    let multiLangList: VisitSeoulMultiLangListValue?
    let mainImg: String?
    let postSj: String?
    let sumry: String?
    let creatDtText: String?
    let updtDtText: String?
}

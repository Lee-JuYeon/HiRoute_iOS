//
//  VisitSeoulContentInfoDTO.swift
//  HiRoute
//
//  Created by Jupond on 5/5/26.
//


struct VisitSeoulContentInfoDTO: Decodable {
    let cid: String
    let langCodeId: String?
    let comCtgrySn: String?
    let cateDepth: VisitSeoulCategoryDepthValue?
    let multiLangList: VisitSeoulMultiLangListValue?
    let mainImg: String?
    let relateImg: [String]?
    let postSj: String?
    let sumry: String?
    let schdulInfoBgnde: String?
    let schdulInfoEndde: String?
    let creatDtText: String?
    let updtDtText: String?
    let tag: [String]?
    let extra: VisitSeoulExtraDTO?
    let traffic: VisitSeoulTrafficDTO?
    let tourist: VisitSeoulTouristDTO?
    let postDesc: String?
}

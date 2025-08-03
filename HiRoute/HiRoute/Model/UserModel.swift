//
//  UserModel.swift
//  HiRoute
//
//  Created by Jupond on 7/26/25.
//

struct UserModel {
    var userUID : String // 내 uid
    var userName : String // 내 이름
    var createPlans : [PlanModel] // 내가 만든 일정
    var writtenReviews : [ReviewModel] // 내가 작성한 리뷰
    var bookMarkedRoutees : [RouteModel]
}

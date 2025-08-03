//
//  SimpleUserModel.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import Foundation

struct PlanModel : Hashable, Codable {
    var planUID : String // 일정 uid
    var planTitle : String // 일정 이름
    var planCreatorUID : String // 일정 생성한 유저의 uid
    var meetingDate : Date // 약속날짜
    var meetingAddress : AddressModel // 약송장소
    var partnerType : PartnerType // 동행 타입
    var activityType : ActivityType // 활동 타입
    var appointmentTimeType : AppointmentTimeType // 약속시간대 타입
    var visitRoutes : [RouteModel] // 해당 일정에서 방문해야할 위치들
    var thumbnailIamgeURL : String // 일정의 썸네일 이미지 경로
}



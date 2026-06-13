//
//  UserAgreementModel.swift
//  HiRoute
//
//  Created by Jupond on 3/1/26.
//

import Foundation

struct UserAgreementModel: Codable {
    // (필수) 서비스 이용약관
    let service: Bool
    let serviceAgreedDate: Date?

    // (필수) 개인정보 수집 및 이용약관
    let privacy: Bool
    let privacyAgreedDate: Date?

    // (필수) 위치기반 서비스 이용약관
    let location: Bool
    let locationAgreedDate: Date?

    // (선택) 마케팅 정보 수신 동의
    let marketing: Bool
    let marketingAgreedDate: Date?

    // (선택) 푸시 알림 수신 동의
    let push: Bool
    let pushAgreedDate: Date?
}

extension UserAgreementModel {
    static func empty() -> UserAgreementModel {
        return UserAgreementModel(
            service: false, serviceAgreedDate: nil,
            privacy: false, privacyAgreedDate: nil,
            location: false, locationAgreedDate: nil,
            marketing: false, marketingAgreedDate: nil,
            push: false, pushAgreedDate: nil
        )
    }
}

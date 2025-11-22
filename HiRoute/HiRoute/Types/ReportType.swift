//
//  ReportType.swift
//  HiRoute
//
//  Created by Jupond on 11/22/25.
//

enum ReportType : String, Codable, CaseIterable {
    case inappropriateLanguage = "부적절한 언어/욕설"
    case spam = "스팸/광고성 글"
    case falseInformation = "허위 정보"
    case irrelevantContent = "장소와 무관한 내용"
    case manipulatedReview = "리뷰 조작 의심"
    case personalInfo = "개인정보 노출"
    case copyright = "저작권 침해"
    case offensiveImage = "불쾌한/부적절한 이미지"
    case violentContent = "폭력적 콘텐츠"
    case other = "기타"
    
    var displayText: String {
        return self.rawValue
    }
}



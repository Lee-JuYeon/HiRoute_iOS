//
//  CommentListModel.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import Foundation

struct ReviewModel : Hashable, Codable, Identifiable {
    var id : String { reviewUid }
    var reviewUid : String // 리뷰 고유 uid
    var reviewText : String? = nil // 리뷰 내용
    var userUid : String // 리뷰 작성자 uid
    var userName : String // 리뷰 작성자 이름
    var visitDate : String? = nil // 방문날짜
    var rating : Int = 0 // 별점 (0~5, 기본값 0)
    var usefulCount : Int = 0 // '도움돼요' 수
    var images : [ImageModel] = [] // 리뷰 이미지
    var usefulList : [UsefulModel]? = nil // 로컬 전용 (API에 없음)

    /// visitDate 문자열을 Date로 변환
    var visitDateAsDate: Date? {
        guard let visitDate else { return nil }
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso.date(from: visitDate) { return date }
        iso.formatOptions = [.withInternetDateTime]
        if let date = iso.date(from: visitDate) { return date }
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.date(from: visitDate)
    }
}

//
//  CommentListModel.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import Foundation

struct ReviewModel : Hashable, Codable, Identifiable {
    var id : String { reviewUID }
    var reviewUID : String // 리뷰 고유 uid
    var reviewText : String // 리뷰 내용
    var userUID : String // 리뷰 작성자 uid
    var userName : String // 리뷰 작성자 이름
    var visitDate : Date // 방문날짜
    var usefulCount : Int // '도움돼요' 수
    var images : [ReviewImageModel] // 리뷰 이미지
    var usefulList : [UsefulModel]
    
}

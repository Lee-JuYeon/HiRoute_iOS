//
//  BookmarkSyncResponse.swift
//  HiRoute
//
//  Created by Jupond on 7/28/25.
//
import Foundation

// 북마크 변경 사항만 서버에 전송

struct BookmarkUpdateRequest: Codable {
    let userUID: String
    let changes: [BookmarkChange]
}

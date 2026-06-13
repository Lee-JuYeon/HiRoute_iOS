//
//  TermDetailResponse.swift
//  HiRoute
//
//  Created by Jupond on 3/13/26.
//

// MARK: - GET /api/terms/active 응답 아이템

struct TermActiveItem: Decodable {
    let id: Int
    let type: String
    let version: Int
    let title: String
}

// MARK: - GET /api/terms/:id 응답 데이터

struct TermDetailData: Decodable {
    let id: Int
    let type: String
    let version: Int
    let title: String
    let contentHtml: String
}

// MARK: - GET /api/terms/:id/content-url 응답 데이터

struct TermContentURLData: Decodable {
    let termsUuid: String
    let downloadUrl: String
    let httpMethod: String
    let expiresAt: String
}

// MARK: - POST /api/terms/consent 요청/응답

struct TermConsentBody: Encodable {
    let termIds: [Int]
}

struct TermConsentResponse: Decodable {
    let message: String
    let count: Int
}

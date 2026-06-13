//
//  VisitSeoulAPIClient.swift
//  HiRoute
//
//  Created by Codex on 5/5/26.
//

import Foundation

final class VisitSeoulAPIClient {
    static let shared = VisitSeoulAPIClient()

    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private init() {
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
    }

    // [SEC-09] 직접 https://api-call.visitseoul.net 호출 + 인앱 VISITSEOUL-API-KEY 제거.
    // 키는 백엔드(api.nunulala.com)가 서버측에서 주입하고, 디바이스는 핀된 HTTPS 프록시만 호출한다.
    // 게스트 지도 브라우징을 고려해 authRefresh:false (401 → 강제 로그아웃 경로 없음).

    func fetchCategoryList() async throws -> [VisitSeoulCategoryDTO] {
        let data = try await APIClient.shared.requestData(
            path: "/api/visitseoul/category/list",
            method: "GET",
            authRefresh: false
        )
        return try decodeEnvelope(data, as: [VisitSeoulCategoryDTO].self).data
    }

    func fetchLanguageCodes() async throws -> [VisitSeoulLanguageCodeDTO] {
        let data = try await APIClient.shared.requestData(
            path: "/api/visitseoul/code/lang",
            method: "GET",
            authRefresh: false
        )
        return try decodeEnvelope(data, as: [VisitSeoulLanguageCodeDTO].self).data
    }

    func fetchContentsList(
        pageNo: Int,
        itemsPerPage: Int,
        comCtgrySn: String? = nil,
        langCodeId: String? = nil,
        keyword: String? = nil,
        sortType: String = "latest"
    ) async throws -> VisitSeoulResponse<[VisitSeoulContentListDTO]> {
        let body = try encoder.encode(
            VisitSeoulContentsListRequest(
                comCtgrySn: comCtgrySn,
                langCodeId: langCodeId,
                keyword: keyword,
                sortType: sortType,
                pageNo: pageNo
            )
        )
        let data = try await APIClient.shared.requestData(
            path: "/api/visitseoul/contents/list",
            method: "POST",
            body: body,
            authRefresh: false
        )
        return try decodeEnvelope(data, as: [VisitSeoulContentListDTO].self)
    }

    func fetchContentInfo(cid: String) async throws -> VisitSeoulResponse<VisitSeoulContentInfoDTO> {
        let body = try encoder.encode(VisitSeoulContentInfoRequest(cid: cid))
        let data = try await APIClient.shared.requestData(
            path: "/api/visitseoul/contents/info",
            method: "POST",
            body: body,
            authRefresh: false
        )
        return try decodeEnvelope(data, as: VisitSeoulContentInfoDTO.self)
    }

    private func decodeEnvelope<T: Decodable>(
        _ data: Data,
        as type: T.Type
    ) throws -> VisitSeoulResponse<T> {
        let envelope = try decoder.decode(VisitSeoulResponse<T>.self, from: data)
        guard envelope.resultCode == 200 else {
            throw VisitSeoulAPIError.apiError(code: envelope.resultCode, message: envelope.resultMessage)
        }
        return envelope
    }
}

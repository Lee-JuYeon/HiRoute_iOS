//
//  JWTHelper.swift
//  HiRoute
//
//  Created by Jupond on 3/12/26.
//

import Foundation

struct JWTHelper {
    private init() {}

    /// Keychain에 저장된 access token JWT에서 uid 추출
    static func extractUIDFromKeychain() -> String? {
        guard let tokenData = try? KeychainService.load(account: "access_token"),
              let token = String(data: tokenData, encoding: .utf8) else { return nil }
        return extractUID(fromJWT: token)
    }

    /// JWT payload에서 uid 필드 추출 (Base64 디코딩만, 서명 검증 불필요)
    static func extractUID(fromJWT token: String) -> String? {
        let segments = token.split(separator: ".")
        guard segments.count == 3 else { return nil }

        var base64 = String(segments[1])
        base64 = base64.replacingOccurrences(of: "-", with: "+")
                        .replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 { base64.append("=") }

        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let uid = json["uid"] as? String else { return nil }
        return uid
    }
}

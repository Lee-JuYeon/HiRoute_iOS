//
//  AuthTokenRequest.swift
//  HiRoute
//
//  Created by Jupond on 3/11/26.
//

struct AuthTokenRequest: Encodable {
    let provider: String
    let token: String
    let name: String?
    /// Apple Sign In replay 방어용 raw nonce. 서버가 id_token.nonce == sha256(rawNonce) 검증.
    /// Apple 외 provider는 nil → JSON에서 생략.
    let rawNonce: String?

    init(provider: String, token: String, name: String?, rawNonce: String? = nil) {
        self.provider = provider
        self.token = token
        self.name = name
        self.rawNonce = rawNonce
    }
}

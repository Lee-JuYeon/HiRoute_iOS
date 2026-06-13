//
//  AppleNonceGenerator.swift
//  HiRoute
//
//  Apple Sign In replay 방어용 nonce 생성기.
//  rawNonce는 백엔드(/api/auth/token)로 전송하고, ASAuthorizationAppleIDRequest.nonce 에는
//  sha256(rawNonce)를 넣는다. 서버는 Apple id_token의 nonce 클레임 == sha256(rawNonce) 를 검증한다.
//
import CryptoKit
import Foundation

enum AppleNonceGenerator {

    /// 암호학적으로 안전한 랜덤 raw nonce 생성.
    static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remaining = length

        while remaining > 0 {
            var randoms = [UInt8](repeating: 0, count: 16)
            let status = SecRandomCopyBytes(kSecRandomDefault, randoms.count, &randoms)
            guard status == errSecSuccess else {
                fatalError("AppleNonceGenerator: SecRandomCopyBytes failed — \(status)")
            }
            for random in randoms {
                if remaining == 0 { break }
                if Int(random) < charset.count {
                    result.append(charset[Int(random)])
                    remaining -= 1
                }
            }
        }
        return result
    }

    /// raw nonce의 SHA-256 hex 문자열. request.nonce 에 넣는 값.
    static func sha256(_ input: String) -> String {
        let hashed = SHA256.hash(data: Data(input.utf8))
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
}

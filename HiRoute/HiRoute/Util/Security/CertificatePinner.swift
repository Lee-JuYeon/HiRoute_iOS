//
//  CertificatePinner.swift
//  HiRoute
//
//  Created by Claude on 3/14/26.
//

import CryptoKit
import Foundation

/// SSL Certificate Pinning — MITM, Evil Twin, DNS Spoofing, ARP Spoofing 방어
/// 자체 관리 leaf SPKI 해시를 핀(primary)하며, CA/leaf 회전 시 brick 방지를 위해
/// standby leaf SPKI(backup)를 함께 핀한다. 회전 절차: docs/ops/cert_pinning_rotation.md
final class CertificatePinner: NSObject, URLSessionDelegate {

    // MARK: - Pinned SPKI SHA-256 Hashes (Base64)
    //
    // primary + backup 2개를 핀하여 단일 핀 brick 위험을 제거한다.
    // backup이 아직 비어 있으면 .filter로 제외 → primary 단일 핀으로 fail-closed 동작.
    private static var pinnedSPKIHashes: Set<String> {
        Set([SecretKeys.certPinHash, SecretKeys.certPinHashBackup].filter { !$0.isEmpty })
    }

    // MARK: - ASN.1 SPKI Headers (DER prefix per key type)

    private static let rsa2048Header: [UInt8] = [
        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09,
        0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
        0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
    ]

    private static let rsa4096Header: [UInt8] = [
        0x30, 0x82, 0x02, 0x22, 0x30, 0x0d, 0x06, 0x09,
        0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
        0x01, 0x05, 0x00, 0x03, 0x82, 0x02, 0x0f, 0x00
    ]

    private static let ecP256Header: [UInt8] = [
        0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2a, 0x86,
        0x48, 0xce, 0x3d, 0x02, 0x01, 0x06, 0x08, 0x2a,
        0x86, 0x48, 0xce, 0x3d, 0x03, 0x01, 0x07, 0x03,
        0x42, 0x00
    ]

    // MARK: - URLSessionDelegate

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // 1. 표준 인증서 체인 검증
        let policy = SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString)
        SecTrustSetPolicies(serverTrust, [policy] as CFArray)

        var error: CFError?
        guard SecTrustEvaluateWithError(serverTrust, &error) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // 2. SPKI 핀 검증 — 체인 내 최소 1개 인증서가 핀과 일치해야 함
        let certCount = SecTrustGetCertificateCount(serverTrust)
        for i in 0..<certCount {
            guard let cert = SecTrustGetCertificateAtIndex(serverTrust, i),
                  let publicKey = SecCertificateCopyKey(cert),
                  let hash = Self.spkiHash(for: publicKey) else {
                continue
            }
            if Self.pinnedSPKIHashes.contains(hash) {
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
                return
            }
        }

        // 핀 불일치 — 연결 거부 (MITM 가능성)
        print("🔒 CertificatePinner: Pin validation failed — connection rejected")
        completionHandler(.cancelAuthenticationChallenge, nil)
    }

    // MARK: - SPKI Hash Computation

    /// 공개키의 SubjectPublicKeyInfo DER → SHA-256 → Base64
    private static func spkiHash(for publicKey: SecKey) -> String? {
        guard let keyData = SecKeyCopyExternalRepresentation(publicKey, nil) as Data? else {
            return nil
        }

        guard let header = spkiHeader(for: publicKey) else { return nil }

        var spki = Data(header)
        spki.append(keyData)

        let hash = SHA256.hash(data: spki)
        return Data(hash).base64EncodedString()
    }

    /// 키 타입/사이즈에 맞는 ASN.1 헤더 반환
    private static func spkiHeader(for publicKey: SecKey) -> [UInt8]? {
        guard let attributes = SecKeyCopyAttributes(publicKey) as? [String: Any] else {
            return nil
        }
        let keyType = attributes[kSecAttrKeyType as String] as? String
        let keySize = (attributes[kSecAttrKeySizeInBits as String] as? Int) ?? 0

        // 정확히 일치하는 키 타입/사이즈만 헤더를 반환(fail-closed).
        // RSA-3072 / EC P-384·P-521 / Ed25519 등 미지원 키는 nil → 핀 스킵(잘못된 해시 계산 방지).
        if keyType == (kSecAttrKeyTypeRSA as String) {
            switch keySize {
            case 2048: return rsa2048Header
            case 4096: return rsa4096Header
            default:   return nil
            }
        } else if keyType == (kSecAttrKeyTypeECSECPrimeRandom as String) {
            return keySize == 256 ? ecP256Header : nil
        }
        return nil
    }
}

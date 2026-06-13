//
//  SEKeyManager.swift
//  HiRoute
//
//  Created by Jupond on 3/1/26.
//

import CryptoKit
import Foundation

struct SEKeyManager {
    private init() {}

    private static let account = "com.nunulala.app.se.masterkey"

    // MARK: - Public

    /// SE 키 로드 (없으면 생성+저장)
    static func getOrCreateKey() throws -> SecureEnclave.P256.KeyAgreement.PrivateKey {
        do {
            return try loadKeyFromKeychain()
        } catch {
            let newKey = try generateKey()
            try storeKeyToKeychain(newKey)
            return newKey
        }
    }

    /// Secure Enclave에서 P256 키 생성
    static func generateKey() throws -> SecureEnclave.P256.KeyAgreement.PrivateKey {
        return try SecureEnclave.P256.KeyAgreement.PrivateKey()
    }

    /// SE 키의 암호화된 blob을 Keychain에 저장
    static func storeKeyToKeychain(_ key: SecureEnclave.P256.KeyAgreement.PrivateKey) throws {
        try KeychainService.save(data: key.dataRepresentation, account: account)
    }

    /// Keychain에서 암호화된 blob 로드 → SE에서 복원
    static func loadKeyFromKeychain() throws -> SecureEnclave.P256.KeyAgreement.PrivateKey {
        let blob = try KeychainService.load(account: account)
        return try SecureEnclave.P256.KeyAgreement.PrivateKey(dataRepresentation: blob)
    }

    /// Keychain에서 SE 키 삭제
    static func deleteKey() {
        KeychainService.delete(account: account)
    }

    // MARK: - 앱 재설치 감지

    /// 앱 재설치 시 이전 SE 키 정리 (UserDefaults는 재설치 시 초기화됨)
    static func handleAppReinstallIfNeeded() {
        let key = "com.nunulala.app.hasLaunchedBefore"
        if !UserDefaults.standard.bool(forKey: key) {
            deleteKey()
            KeychainService.delete(account: "access_token")
            KeychainService.delete(account: "refresh_token")
            UserDefaults.standard.set(true, forKey: key)
        }
    }
}

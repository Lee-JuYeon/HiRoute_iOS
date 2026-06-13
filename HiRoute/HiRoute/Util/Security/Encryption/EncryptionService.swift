//
//  EncryptionService.swift
//  HiRoute
//
//  Created by Jupond on 3/1/26.
//

import CryptoKit
import Foundation
import Security

struct EncryptionService {
    private init() {}

    private static let sharedInfo = Data("com.nunulala.app.encryption".utf8)
    private static let saltSize = 32
    private static let publicKeySize = 65 // P256 x963Representation

    // MARK: - Public

    /// Data → AES-GCM 암호화 (SE ECDH + HKDF → AES-256 key 파생)
    /// 저장 형식: ephemeralPublicKey(65B) + salt(32B) + combined(nonce+ciphertext+tag)
    static func encrypt(_ plainData: Data) throws -> Data {
        let seKey = try SEKeyManager.getOrCreateKey()
        let ephemeralKey = P256.KeyAgreement.PrivateKey()
        let sharedSecret = try seKey.sharedSecretFromKeyAgreement(with: ephemeralKey.publicKey)

        var salt = Data(count: saltSize)
        salt.withUnsafeMutableBytes { _ = SecRandomCopyBytes(kSecRandomDefault, saltSize, $0.baseAddress!) }

        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: salt,
            sharedInfo: sharedInfo,
            outputByteCount: 32
        )

        let sealedBox = try AES.GCM.seal(plainData, using: symmetricKey)
        guard let combined = sealedBox.combined else {
            throw EncryptionError.sealFailed
        }

        var result = Data()
        result.append(ephemeralKey.publicKey.x963Representation)
        result.append(salt)
        result.append(combined)
        return result
    }

    /// AES-GCM 암호화 Data → 복호화
    static func decrypt(_ encryptedData: Data) throws -> Data {
        guard encryptedData.count > publicKeySize + saltSize else {
            throw EncryptionError.invalidData
        }

        let ephemeralPublicKeyData = encryptedData.prefix(publicKeySize)
        let salt = encryptedData[publicKeySize..<(publicKeySize + saltSize)]
        let combined = encryptedData[(publicKeySize + saltSize)...]

        let seKey = try SEKeyManager.getOrCreateKey()
        let ephemeralPublicKey = try P256.KeyAgreement.PublicKey(x963Representation: ephemeralPublicKeyData)
        let sharedSecret = try seKey.sharedSecretFromKeyAgreement(with: ephemeralPublicKey)

        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: salt,
            sharedInfo: sharedInfo,
            outputByteCount: 32
        )

        let sealedBox = try AES.GCM.SealedBox(combined: combined)
        return try AES.GCM.open(sealedBox, using: symmetricKey)
    }
}

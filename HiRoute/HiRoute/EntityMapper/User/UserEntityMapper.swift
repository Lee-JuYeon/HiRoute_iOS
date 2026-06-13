//
//  UserEntityMapper.swift
//  HiRoute
//
//  Created by Jupond on 3/1/26.
//

import CoreData
import Foundation

struct UserEntityMapper {

    // MARK: - toEntity (암호화)

    static func toEntity(_ model: UserModel, context: NSManagedObjectContext) throws -> UserEntity {
        let entity = UserEntity(context: context)

        // uid는 평문 (CoreData PK/조회용)
        entity.uid = model.uid

        // 필드 암호화
        entity.encryptedName = try EncryptionService.encrypt(Data(model.name.utf8))
        entity.encryptedNationality = try EncryptionService.encrypt(Data(model.nationality.utf8))
        entity.encryptedGender = try EncryptionService.encrypt(Data(model.gender.rawValue.utf8))

        if let age = model.age {
            entity.encryptedAge = try EncryptionService.encrypt(Data(String(age).utf8))
        }

        // agreements (Bool + Optional Date)
        entity.encryptedAgreedService = try encryptBool(model.agreements.service)
        entity.encryptedAgreedServiceDate = try encryptOptionalDate(model.agreements.serviceAgreedDate)
        entity.encryptedAgreedPrivacy = try encryptBool(model.agreements.privacy)
        entity.encryptedAgreedPrivacyDate = try encryptOptionalDate(model.agreements.privacyAgreedDate)
        entity.encryptedAgreedLocation = try encryptBool(model.agreements.location)
        entity.encryptedAgreedLocationDate = try encryptOptionalDate(model.agreements.locationAgreedDate)
        entity.encryptedAgreedMarketing = try encryptBool(model.agreements.marketing)
        entity.encryptedAgreedMarketingDate = try encryptOptionalDate(model.agreements.marketingAgreedDate)
        entity.encryptedAgreedPush = try encryptBool(model.agreements.push)
        entity.encryptedAgreedPushDate = try encryptOptionalDate(model.agreements.pushAgreedDate)

        // dates
        entity.encryptedCreatedDate = try encryptDate(model.createdDate)
        entity.encryptedEditDate = try encryptDate(model.editDate)

        return entity
    }

    // MARK: - toModel (복호화 + defer zeroing)

    static func toModel(_ entity: UserEntity?) throws -> UserModel? {
        guard let entity = entity,
              let uid = entity.uid,
              let encName = entity.encryptedName,
              let encNationality = entity.encryptedNationality,
              let encGender = entity.encryptedGender,
              let encAgreedService = entity.encryptedAgreedService,
              let encAgreedPrivacy = entity.encryptedAgreedPrivacy,
              let encAgreedLocation = entity.encryptedAgreedLocation,
              let encAgreedMarketing = entity.encryptedAgreedMarketing,
              let encAgreedPush = entity.encryptedAgreedPush,
              let encCreatedDate = entity.encryptedCreatedDate,
              let encEditDate = entity.encryptedEditDate
        else { return nil }

        // 필수 필드 복호화
        var dName = try EncryptionService.decrypt(encName)
        var dNationality = try EncryptionService.decrypt(encNationality)
        var dGender = try EncryptionService.decrypt(encGender)
        var dAgreedService = try EncryptionService.decrypt(encAgreedService)
        var dAgreedPrivacy = try EncryptionService.decrypt(encAgreedPrivacy)
        var dAgreedLocation = try EncryptionService.decrypt(encAgreedLocation)
        var dAgreedMarketing = try EncryptionService.decrypt(encAgreedMarketing)
        var dAgreedPush = try EncryptionService.decrypt(encAgreedPush)
        var dCreatedDate = try EncryptionService.decrypt(encCreatedDate)
        var dEditDate = try EncryptionService.decrypt(encEditDate)

        // Optional 필드 복호화
        var dAge = try decryptOptional(entity.encryptedAge)
        var dServiceDate = try decryptOptional(entity.encryptedAgreedServiceDate)
        var dPrivacyDate = try decryptOptional(entity.encryptedAgreedPrivacyDate)
        var dLocationDate = try decryptOptional(entity.encryptedAgreedLocationDate)
        var dMarketingDate = try decryptOptional(entity.encryptedAgreedMarketingDate)
        var dPushDate = try decryptOptional(entity.encryptedAgreedPushDate)

        // defer zeroing — heap 보호 (함수 종료 시 모든 복호화 Data를 0으로 채움)
        defer {
            zeroData(&dName)
            zeroData(&dNationality)
            zeroData(&dGender)
            zeroData(&dAgreedService)
            zeroData(&dAgreedPrivacy)
            zeroData(&dAgreedLocation)
            zeroData(&dAgreedMarketing)
            zeroData(&dAgreedPush)
            zeroData(&dCreatedDate)
            zeroData(&dEditDate)
            zeroOptionalData(&dAge)
            zeroOptionalData(&dServiceDate)
            zeroOptionalData(&dPrivacyDate)
            zeroOptionalData(&dLocationDate)
            zeroOptionalData(&dMarketingDate)
            zeroOptionalData(&dPushDate)
        }

        let name = String(data: dName, encoding: .utf8) ?? ""
        let nationality = String(data: dNationality, encoding: .utf8) ?? ""
        let gender = GenderType(rawValue: String(data: dGender, encoding: .utf8) ?? "") ?? .male
        let age: Int? = dAge.flatMap { Int(String(data: $0, encoding: .utf8) ?? "") }

        let agreements = UserAgreementModel(
            service: decodeBool(dAgreedService),
            serviceAgreedDate: decodeOptionalDate(dServiceDate),
            privacy: decodeBool(dAgreedPrivacy),
            privacyAgreedDate: decodeOptionalDate(dPrivacyDate),
            location: decodeBool(dAgreedLocation),
            locationAgreedDate: decodeOptionalDate(dLocationDate),
            marketing: decodeBool(dAgreedMarketing),
            marketingAgreedDate: decodeOptionalDate(dMarketingDate),
            push: decodeBool(dAgreedPush),
            pushAgreedDate: decodeOptionalDate(dPushDate)
        )

        return UserModel(
            uid: uid,
            name: name,
            nationality: nationality,
            gender: gender,
            age: age,
            agreements: agreements,
            createdDate: decodeDate(dCreatedDate),
            editDate: decodeDate(dEditDate)
        )
    }

    // MARK: - Encryption Helpers

    private static func encryptBool(_ value: Bool) throws -> Data {
        return try EncryptionService.encrypt(Data([value ? 1 : 0]))
    }

    private static func encryptDate(_ date: Date) throws -> Data {
        return try EncryptionService.encrypt(Data(String(date.timeIntervalSince1970).utf8))
    }

    private static func encryptOptionalDate(_ date: Date?) throws -> Data? {
        guard let date = date else { return nil }
        return try encryptDate(date)
    }

    // MARK: - Decryption Helpers

    private static func decryptOptional(_ data: Data?) throws -> Data? {
        guard let data = data else { return nil }
        return try EncryptionService.decrypt(data)
    }

    private static func decodeBool(_ data: Data) -> Bool {
        return data.first == 1
    }

    private static func decodeDate(_ data: Data) -> Date {
        let timeInterval = Double(String(data: data, encoding: .utf8) ?? "0") ?? 0
        return Date(timeIntervalSince1970: timeInterval)
    }

    private static func decodeOptionalDate(_ data: Data?) -> Date? {
        guard let data = data else { return nil }
        return decodeDate(data)
    }

    // MARK: - Zeroing Helpers

    private static func zeroData(_ data: inout Data) {
        guard !data.isEmpty else { return }
        data.resetBytes(in: 0..<data.count)
    }

    private static func zeroOptionalData(_ data: inout Data?) {
        guard var d = data, !d.isEmpty else { return }
        d.resetBytes(in: 0..<d.count)
        data = nil
    }
}

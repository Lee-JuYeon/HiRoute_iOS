//
//  ScheduleChatEntityMapper.swift
//  HiRoute
//
//  Created by Jupond on 5/20/26.
//

import Foundation
import CoreData

/// 일정 소속 대화 기록(ScheduleChatEntity) ↔ ChatMessageModel 매핑.
/// 채팅 == 일정이므로 모든 메시지는 ScheduleChatEntity로 저장됨.
struct ScheduleChatEntityMapper {
    static func toModel(_ entity: ScheduleChatEntity?) -> ChatMessageModel? {
        guard let entity = entity,
              let uid = entity.uid,
              let roleRaw = entity.role,
              let role = ChatRole(rawValue: roleRaw) else { return nil }

        return ChatMessageModel(
            uid: uid,
            role: role,
            content: entity.content ?? "",
            createdAt: entity.createdAt ?? Date(),
            attachedPlaces: decodePlaces(entity.attachedPlacesJSON)
        )
    }

    /// [2026-05-26 Phase 3] 활성 메시지만 반환 (soft-deleted 제외).
    /// 삭제된 메시지를 보려면 toModelsIncludingDeleted 사용.
    static func toModels(_ entities: Set<ScheduleChatEntity>?) -> [ChatMessageModel] {
        guard let entities = entities else { return [] }
        return entities
            .filter { $0.deletedAt == nil }
            .compactMap { toModel($0) }
            .sorted { $0.createdAt < $1.createdAt }
    }

    /// [2026-05-26 Phase 3] 복구 화면(RecoveryView)에서 사용 — 삭제된 메시지 포함 전체.
    /// `(message, deletedAt)` 쌍으로 반환하므로 UI에서 grace period 계산 가능.
    static func toModelsIncludingDeleted(_ entities: Set<ScheduleChatEntity>?) -> [(message: ChatMessageModel, deletedAt: Date?)] {
        guard let entities = entities else { return [] }
        return entities
            .compactMap { entity -> (ChatMessageModel, Date?)? in
                guard let model = toModel(entity) else { return nil }
                return (model, entity.deletedAt)
            }
            .sorted { $0.0.createdAt < $1.0.createdAt }
    }

    static func toEntity(_ model: ChatMessageModel, schedule: ScheduleEntity, context: NSManagedObjectContext) -> ScheduleChatEntity {
        let entity = ScheduleChatEntity(context: context)
        entity.uid = model.uid
        entity.role = model.role.rawValue
        entity.content = model.content
        entity.createdAt = model.createdAt
        entity.attachedPlacesJSON = encodePlaces(model.attachedPlaces)
        entity.schedule = schedule
        return entity
    }

    // MARK: - Attached places encode/decode

    private static func encodePlaces(_ places: [PlaceModel]?) -> String? {
        guard let places = places, !places.isEmpty else { return nil }
        guard let data = try? JSONEncoder().encode(places) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private static func decodePlaces(_ json: String?) -> [PlaceModel]? {
        guard let json = json, !json.isEmpty,
              let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode([PlaceModel].self, from: data)
    }
}

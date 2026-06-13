//
//  ScheduleResponse.swift
//  HiRoute
//
//  Created by Jupond on 5/5/26.
//

import Foundation

struct ScheduleResponse: Decodable {
    let uid: String
    let userUid: String
    let indexOrder: Int
    let title: String
    let memo: String
    let dDay: String
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let plans: [PlanResponse]
    // [2026-05-27 Phase A.1] 서버가 보내는 chat_history. 옵셔널 (구버전 호환).
    let chatHistory: [ChatMessageResponse]?
}


extension ScheduleResponse {
    func toModel() -> ScheduleModel {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let dDayDate = isoFormatter.date(from: dDay) ?? Date()
        let editDateParsed = isoFormatter.date(from: updatedAt) ?? Date()

        // [2026-05-27 Phase A.1] 서버 chat_history → 클라 ChatMessageModel.
        // attached_places_json은 JSON 디코딩 시도 (실패 시 nil).
        let messages: [ChatMessageModel] = (chatHistory ?? []).compactMap { resp in
            guard let role = ChatRole(rawValue: resp.role) else { return nil }
            let createdAtDate = isoFormatter.date(from: resp.createdAt) ?? Date()
            let places = ChatMessageResponseHelper.decodePlaces(resp.attachedPlacesJson)
            return ChatMessageModel(
                uid: resp.uid,
                role: role,
                content: resp.content,
                createdAt: createdAtDate,
                attachedPlaces: places
            )
        }

        return ScheduleModel(
            uid: uid,
            index: indexOrder,
            title: title,
            memo: memo,
            editDate: editDateParsed,
            d_day: dDayDate,
            planList: plans.map { $0.toModel() },
            chatHistory: messages
        )
    }
}

/// attached_places_json (서버) ↔ [PlaceModel] (클라) 인코딩/디코딩 헬퍼.
enum ChatMessageResponseHelper {
    static func decodePlaces(_ json: String?) -> [PlaceModel]? {
        guard let json = json, !json.isEmpty,
              let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode([PlaceModel].self, from: data)
    }

    static func encodePlaces(_ places: [PlaceModel]?) -> String? {
        guard let places = places, !places.isEmpty else { return nil }
        guard let data = try? JSONEncoder().encode(places) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

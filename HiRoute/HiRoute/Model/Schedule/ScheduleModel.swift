//
//  ScheduleModel.swift
//  HiRoute
//
//  Created by Jupond on 7/20/25.
//
import Foundation

struct ScheduleModel: Codable, Identifiable, Hashable {
    var id: String { uid } // ✅ Identifiable 프로토콜 구현

    let uid: String
    let index: Int
    let title: String
    let memo: String
    let editDate: Date
    let d_day: Date
    let planList: [PlanModel]
    /// 이 일정이 만들어진 대화 기록 (선택, 클라이언트 전용).
    /// CoreData ScheduleChatEntity 1:N로 영속화. API DTO 직렬화 미포함.
    let chatHistory: [ChatMessageModel]

    init(
        uid: String,
        index: Int,
        title: String,
        memo: String,
        editDate: Date,
        d_day: Date,
        planList: [PlanModel],
        chatHistory: [ChatMessageModel] = []
    ) {
        self.uid = uid
        self.index = index
        self.title = title
        self.memo = memo
        self.editDate = editDate
        self.d_day = d_day
        self.planList = planList
        self.chatHistory = chatHistory
    }

    func updateModel(_ newModel : ScheduleModel) -> ScheduleModel {
        return ScheduleModel(
            uid: newModel.uid,
            index: newModel.index,
            title: newModel.title,
            memo: newModel.memo,  // 새로운 값
            editDate: newModel.editDate,
            d_day: newModel.d_day,
            planList: newModel.planList,
            chatHistory: newModel.chatHistory
        )
    }

    /// [2026-05-26] 부분 업데이트 헬퍼 (랄프 루프 Phase 1).
    /// 호출부가 일부 필드만 바꾸려고 `ScheduleModel(...)` 풀 생성자를 부르면서
    /// `chatHistory:` 누락 → wipe 버그. 이 헬퍼는 누락된 필드는 self의 현재 값으로
    /// preserve하므로 chatHistory가 의도치 않게 사라지지 않는다.
    ///
    /// 사용 예: `schedule.copy(title: newTitle)` — title만 바뀌고 나머지 보존.
    /// editDate는 명시 안 하면 호출 시각으로 자동 갱신 (편집 의도 기본 동작).
    func copy(
        title: String? = nil,
        memo: String? = nil,
        editDate: Date? = nil,
        d_day: Date? = nil,
        planList: [PlanModel]? = nil,
        chatHistory: [ChatMessageModel]? = nil
    ) -> ScheduleModel {
        ScheduleModel(
            uid: self.uid,
            index: self.index,
            title: title ?? self.title,
            memo: memo ?? self.memo,
            editDate: editDate ?? Date(),
            d_day: d_day ?? self.d_day,
            planList: planList ?? self.planList,
            chatHistory: chatHistory ?? self.chatHistory
        )
    }
}

extension ScheduleModel {
    /// 클라 chatHistory를 서버 DTO 배열로 변환.
    /// [2026-05-27 Phase A.1] attached_places_json은 ChatMessageResponseHelper로 직렬화.
    fileprivate func chatHistoryRequests(formatter: ISO8601DateFormatter) -> [ChatMessageRequest] {
        chatHistory.map { msg in
            ChatMessageRequest(
                uid: msg.uid,
                role: msg.role.rawValue,
                content: msg.content,
                attachedPlacesJson: ChatMessageResponseHelper.encodePlaces(msg.attachedPlaces),
                createdAt: formatter.string(from: msg.createdAt),
                deletedAt: nil
            )
        }
    }

    fileprivate func planRequests() -> [PlanCreateRequest] {
        planList.map { plan in
            PlanCreateRequest(
                uid: plan.uid,
                placeUid: plan.placeModel.uid.isEmpty ? nil : plan.placeModel.uid,
                indexOrder: plan.index,
                memo: plan.memo,
                files: plan.files.map { PlanFileRequest(filePath: $0.filePath, fileType: $0.fileType) }
            )
        }
    }

    func toCreateRequest() -> ScheduleCreateRequest {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return ScheduleCreateRequest(
            uid: uid,
            title: title,
            memo: memo,
            dDay: formatter.string(from: d_day),
            indexOrder: index,
            plans: planRequests(),
            chatHistory: chatHistoryRequests(formatter: formatter)
        )
    }

    func toSyncUpdateItem() -> ScheduleSyncUpdateItem {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return ScheduleSyncUpdateItem(
            uid: uid,
            title: title,
            memo: memo,
            dDay: formatter.string(from: d_day),
            plans: planRequests(),
            chatHistory: chatHistoryRequests(formatter: formatter),
            updatedAt: formatter.string(from: editDate)
        )
    }

    func toUpdateRequest() -> ScheduleUpdateRequest {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return ScheduleUpdateRequest(
            title: title,
            memo: memo,
            dDay: formatter.string(from: d_day),
            plans: planRequests(),
            chatHistory: chatHistoryRequests(formatter: formatter)
        )
    }
}

// MARK: - SidebarItem 준수
// 범용 SidebarListView에서 일정 목록 렌더에 사용.

extension ScheduleModel: SidebarItem {
    var sidebarTitle: String {
        title.isEmpty ? "새 일정" : title
    }

    var sidebarIconName: String {
        "bubble.left"
    }

    /// 사이드바 row 부제 — 일정의 d_day "yyyy.MM.dd"
    var sidebarSubtitle: String? {
        ScheduleModel.sidebarDateFormatter.string(from: d_day)
    }

    private static let sidebarDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }()
}

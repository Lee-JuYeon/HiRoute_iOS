//
//  ChatVM.swift
//  HiRoute
//
//  Created by Jupond on 5/20/26.
//

import Foundation
import SwiftUI
import Combine

/// 채팅 == 일정. ScheduleModel 하나로 모든 상태를 관리.
/// - 메시지 = currentSchedule.chatHistory (UI 즉시 반영용으로 messages도 mirror)
/// - 사이드바 = ScheduleService.readAll
/// - persistence = ScheduleService
/// - AI 응답 스트리밍 = ChatService (대화 CRUD 책임 없음)
final class ChatVM: ObservableObject {

    // MARK: - Published State

    @Published private(set) var currentSchedule: ScheduleModel?
    @Published private(set) var messages: [ChatMessageModel] = []
    @Published private(set) var streamingText: String = ""
    @Published private(set) var streamingPlaces: [PlaceModel] = []
    /// 스트리밍 중 받은 추천 코스 (코스 카드용). [2026-06-07 AI 연동]
    @Published private(set) var streamingRecommendation: AIRecommendation?
    @Published private(set) var isStreaming: Bool = false
    @Published var inputText: String = ""

    /// 대화로 누적된 여행 선호 프로필 (서버 세션). 다음 턴에 재전송. [2026-06-07]
    /// (영속화 1.B는 후속: 현재는 메모리 보관)
    private var aiProfile: AITravelProfile = .empty

    /// 사이드바에 노출할 일정 목록 (editDate 내림차순)
    @Published private(set) var schedules: [ScheduleModel] = []

    // MARK: - Deps

    private let chatService: ChatService
    private let scheduleService: ScheduleService
    private var streamCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    private var hasLoadedLatest: Bool = false

    init(chatService: ChatService, scheduleService: ScheduleService) {
        self.chatService = chatService
        self.scheduleService = scheduleService
        print("ChatVM, init // Success")
    }

    // MARK: - Lifecycle

    /// PlannerView가 다시 보일 때(.onAppear) 호출.
    /// 외부(PlaceView "일정에 추가" 등)에서 일정이 바뀌었을 수 있으니 DB에서 재조회.
    /// 첫 호출 시엔 최신 일정 자동 선택.
    func refresh() {
        refreshSchedules { [weak self] list in
            guard let self = self else { return }

            if let currentUID = self.currentSchedule?.uid {
                // 기존 currentSchedule 있음 → DB 최신본으로 갱신 (planList 변경 등 반영)
                if let updated = list.first(where: { $0.uid == currentUID }) {
                    self.currentSchedule = updated
                    // 스트리밍 중엔 messages 덮어쓰지 않음 (사용자 입력 중일 가능성)
                    if !self.isStreaming {
                        self.messages = updated.chatHistory
                    }
                } else {
                    // 외부에서 삭제됨
                    self.startNewSchedule()
                }
            } else if !self.hasLoadedLatest {
                // 첫 로드 — 최신 일정 자동 선택
                self.hasLoadedLatest = true
                if let latest = list.first {
                    self.currentSchedule = latest
                    self.messages = latest.chatHistory
                    print("ChatVM, refresh // 첫 로드: \(latest.uid)")
                } else {
                    print("ChatVM, refresh // 저장된 일정 없음")
                }
            }
            // else: currentSchedule nil + 이미 첫 로드 끝남 (사용자가 startNewSchedule 호출 상태) — 그대로 둠
        }
    }

    func refreshSchedules(_ completion: (([ScheduleModel]) -> Void)? = nil) {
        scheduleService.readAll(page: 0, itemsPerPage: 100)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] list in
                    self?.schedules = list
                    completion?(list)
                }
            )
            .store(in: &cancellables)
    }

    func selectSchedule(uid: String) {
        guard currentSchedule?.uid != uid else { return }
        cancelStreaming()
        scheduleService.read(uid: uid)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { result in
                    if case .failure(let error) = result {
                        print("ChatVM, selectSchedule // 실패: \(error)")
                    }
                },
                receiveValue: { [weak self] schedule in
                    guard let self = self else { return }
                    self.currentSchedule = schedule
                    self.messages = schedule.chatHistory
                    self.streamingText = ""
                    self.streamingPlaces = []
                    self.inputText = ""
                }
            )
            .store(in: &cancellables)
    }

    func deleteSchedule(uid: String) {
        let wasCurrent = (currentSchedule?.uid == uid)
        scheduleService.delete(uid: uid)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] _ in
                    guard let self = self else { return }
                    self.refreshSchedules()
                    if wasCurrent {
                        self.cancelStreaming()
                        self.currentSchedule = nil
                        self.messages = []
                        self.streamingText = ""
                        self.streamingPlaces = []
                    }
                }
            )
            .store(in: &cancellables)
    }

    func startNewSchedule() {
        cancelStreaming()
        currentSchedule = nil
        messages = []
        streamingText = ""
        streamingPlaces = []
        inputText = ""
    }

    // MARK: - Send

    func send() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isStreaming else { return }

        inputText = ""

        // [2026-05-27 Phase C.5+C.6] PII 마스킹 + prompt injection 차단.
        // 저장/표시도 마스킹된 ver로 — 외부 LLM 호출 + 다른 기기 sync 시 PII leak 방지.
        let sanitized = ChatSanitizer.sanitizeForLLM(trimmed)

        let userMessage = ChatMessageModel(
            uid: UUID().uuidString,
            role: .user,
            content: sanitized,
            createdAt: Date()
        )

        ensureSchedule(titleHint: sanitized) { [weak self] schedule in
            guard let self = self, let schedule = schedule else { return }
            self.appendAndStream(userMessage: userMessage, schedule: schedule)
        }
    }

    func sendSuggestion(_ suggestion: String) {
        inputText = suggestion
        send()
    }

    func cancelStreaming() {
        streamCancellable?.cancel()
        streamCancellable = nil
        if isStreaming {
            finalizeStreamingMessage(saveIfEmpty: false)
        }
    }

    // MARK: - Schedule Edits

    /// 일정 제목 수정 — 없으면 만들고 수정.
    func updateScheduleTitle(_ newTitle: String) {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        ensureSchedule(titleHint: trimmed) { [weak self] schedule in
            guard let self = self, let schedule = schedule else { return }
            self.scheduleService.updateScheduleInfo(uid: schedule.uid, title: trimmed, memo: schedule.memo, dDay: schedule.d_day)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { result in
                        if case .failure(let error) = result {
                            print("ChatVM, updateScheduleTitle // 실패: \(error)")
                        }
                    },
                    receiveValue: { [weak self] updated in
                        self?.currentSchedule = updated
                        self?.refreshSchedules()
                    }
                )
                .store(in: &self.cancellables)
        }
    }

    /// 일정 d_day 변경 — 없으면 만들고 변경.
    func updateScheduleDDay(_ newDate: Date) {
        ensureSchedule(titleHint: "새 일정", initialDDay: newDate) { [weak self] schedule in
            guard let self = self, let schedule = schedule else { return }
            self.scheduleService.updateScheduleInfo(uid: schedule.uid, title: schedule.title, memo: schedule.memo, dDay: newDate)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { result in
                        if case .failure(let error) = result {
                            print("ChatVM, updateScheduleDDay // 실패: \(error)")
                        }
                    },
                    receiveValue: { [weak self] updated in
                        self?.currentSchedule = updated
                        self?.refreshSchedules()
                    }
                )
                .store(in: &self.cancellables)
        }
    }

    // MARK: - Internal

    /// currentSchedule 있으면 그대로, 없으면 DB에 생성 후 반환.
    private func ensureSchedule(titleHint: String, initialDDay: Date = Date(), completion: @escaping (ScheduleModel?) -> Void) {
        if let existing = currentSchedule {
            completion(existing)
            return
        }

        let title = makeTitle(from: titleHint)
        let seed = ScheduleModel(
            uid: UUID().uuidString,
            index: 0,
            title: title,
            memo: "",
            editDate: Date(),
            d_day: initialDDay,
            planList: [],
            chatHistory: []
        )

        scheduleService.create(seed)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] result in
                    if case .failure(let error) = result {
                        print("ChatVM, ensureSchedule // create 실패: \(error)")
                        self?.currentSchedule = nil
                        completion(nil)
                    }
                },
                receiveValue: { [weak self] created in
                    self?.currentSchedule = created
                    self?.refreshSchedules()
                    completion(created)
                }
            )
            .store(in: &cancellables)
    }

    private func appendAndStream(userMessage: ChatMessageModel, schedule: ScheduleModel) {
        // 1) UI 즉시 반영
        messages.append(userMessage)

        // 2) DB 영속화
        scheduleService.appendChatMessage(scheduleUID: schedule.uid, message: userMessage)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)

        // 3) AI 응답 스트리밍
        isStreaming = true
        streamingText = ""
        streamingPlaces = []
        streamingRecommendation = nil

        // 서버로 보낼 세션: 직전까지의 히스토리(현재 user 메시지 제외, 서버가 추가) + 누적 프로필
        let priorHistory = messages.dropLast().map {
            AIChatHistoryItem(role: $0.role == .user ? "user" : "assistant", content: $0.content)
        }
        let session = AIChatSession(profile: aiProfile, history: Array(priorHistory))

        let scheduleUID = schedule.uid
        streamCancellable = chatService
            .streamAssistantReply(for: userMessage, session: session)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] _ in
                    guard let self = self else { return }
                    self.finalizeStreamingMessage(saveIfEmpty: false, scheduleUID: scheduleUID)
                },
                receiveValue: { [weak self] event in
                    guard let self = self else { return }
                    switch event {
                    case .chunk(let chunk):
                        self.streamingText.append(chunk)
                    case .attach(let places):
                        self.streamingPlaces.append(contentsOf: places)
                    case .recommendation(let rec):
                        self.streamingRecommendation = rec
                    case .session(let s):
                        self.aiProfile = s.profile
                    case .finished:
                        self.finalizeStreamingMessage(saveIfEmpty: false, scheduleUID: scheduleUID)
                    }
                }
            )
    }

    private func finalizeStreamingMessage(saveIfEmpty: Bool, scheduleUID: String? = nil) {
        guard isStreaming else { return }
        let finalContent = streamingText
        let finalPlaces = streamingPlaces
        let finalRecommendation = streamingRecommendation
        streamingText = ""
        streamingPlaces = []
        streamingRecommendation = nil
        isStreaming = false
        streamCancellable = nil

        guard !finalContent.isEmpty || !finalPlaces.isEmpty || saveIfEmpty else { return }

        let assistantMessage = ChatMessageModel(
            uid: UUID().uuidString,
            role: .assistant,
            content: finalContent,
            createdAt: Date(),
            attachedPlaces: finalPlaces.isEmpty ? nil : finalPlaces,
            recommendation: finalRecommendation
        )
        messages.append(assistantMessage)

        let targetUID = scheduleUID ?? currentSchedule?.uid
        if let targetUID = targetUID {
            scheduleService.appendChatMessage(scheduleUID: targetUID, message: assistantMessage)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { [weak self] _ in self?.refreshSchedules() }
                )
                .store(in: &cancellables)
        }
    }

    private func makeTitle(from content: String) -> String {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count <= 20 { return trimmed }
        return String(trimmed.prefix(20)) + "…"
    }
}

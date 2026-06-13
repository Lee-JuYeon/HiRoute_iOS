//
//  ChatService.swift
//  HiRoute
//
//  Created by Jupond on 5/20/26.
//  [2026-06-07] AI 연동: 세션 전달.
//

import Foundation
import Combine

/// AI 응답 스트리밍 전용 (대화 CRUD는 ScheduleService가 담당).
final class ChatService {
    private let chatProtocol: ChatProtocol

    init(chatProtocol: ChatProtocol) {
        self.chatProtocol = chatProtocol
        print("ChatService, init // Success")
    }

    func streamAssistantReply(for userMessage: ChatMessageModel,
                              session: AIChatSession) -> AnyPublisher<ChatStreamEvent, Never> {
        chatProtocol.streamAssistantReply(for: userMessage, session: session)
    }
}

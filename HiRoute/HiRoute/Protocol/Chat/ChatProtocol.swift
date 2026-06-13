//
//  ChatProtocol.swift
//  HiRoute
//
//  Created by Jupond on 5/20/26.
//  [2026-06-07] AI 연동: 대화 세션(프로필+히스토리) 전달.
//

import Foundation
import Combine

/// AI 응답 스트리밍 전용. 대화/메시지 영속화는 ScheduleService가 담당 (채팅 == 일정).
protocol ChatProtocol {
    func streamAssistantReply(for userMessage: ChatMessageModel,
                              session: AIChatSession) -> AnyPublisher<ChatStreamEvent, Never>
}

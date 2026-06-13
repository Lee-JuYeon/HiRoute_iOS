//
//  ChatStreamingSession.swift
//  HiRoute
//
//  Created by Jupond on 5/20/26.
//

import Foundation
import Combine

/// iOS 14 호환 더미 스트리밍 세션.
/// DispatchWorkItem 기반으로 응답 문자열을 한 글자씩 emit. 텍스트가 끝나면 첨부 장소를 한 번에 emit. 구독 해제 시 cancel.
final class ChatStreamingSession {
    private let characters: [String]
    private let attachedPlaces: [PlaceModel]
    private let subject: PassthroughSubject<ChatStreamEvent, Never>
    private var index: Int = 0
    private var pendingWork: DispatchWorkItem?
    private var isCancelled: Bool = false

    init(response: String, attachedPlaces: [PlaceModel] = [], subject: PassthroughSubject<ChatStreamEvent, Never>) {
        self.characters = response.map { String($0) }
        self.attachedPlaces = attachedPlaces
        self.subject = subject
    }

    func start() {
        guard !isCancelled else { return }
        scheduleNext(after: 0.3)
    }

    func cancel() {
        isCancelled = true
        pendingWork?.cancel()
        pendingWork = nil
    }

    private func scheduleNext(after delay: TimeInterval) {
        let work = DispatchWorkItem { [weak self] in self?.emitNext() }
        pendingWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
    }

    private func emitNext() {
        guard !isCancelled else { return }
        if index >= characters.count {
            if !attachedPlaces.isEmpty {
                subject.send(.attach(places: attachedPlaces))
            }
            subject.send(.finished)
            subject.send(completion: .finished)
            return
        }
        subject.send(.chunk(characters[index]))
        index += 1
        scheduleNext(after: 0.025) // 25ms per char
    }
}

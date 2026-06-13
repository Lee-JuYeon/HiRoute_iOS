//
//  AIChatRepository.swift
//  HiRoute
//
//  [2026-06-07] 실제 AI 챗 서버(nunulala-ml chatTurn) 호출. 더미 ChatRepository 대체.
//  POST /chat → AIChatResponse → ChatStreamEvent(chunk/attach/recommendation/session/finished).
//
import Foundation
import Combine

final class AIChatRepository: ChatProtocol {

    init() { print("AIChatRepository, init // Success") }

    func streamAssistantReply(for userMessage: ChatMessageModel,
                              session: AIChatSession) -> AnyPublisher<ChatStreamEvent, Never> {
        let subject = PassthroughSubject<ChatStreamEvent, Never>()

        var request = URLRequest(url: AIChatConfig.chatEndpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try? encoder.encode(AIChatRequest(message: userMessage.content, session: session))

        // [SEC] api.nunulala.com 첫-파티 호출 — CertificatePinner를 단 핀된 세션 경유(MITM 방어).
        // URLSession.shared는 delegate를 못 달아 UNPINNED였음. /api/ai/chat은 의도적으로 비인증.
        let task = PinnedURLSessionProvider.shared.streamingSession.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                func finish(_ text: String) {
                    subject.send(.chunk(text))
                    subject.send(.finished)
                    subject.send(completion: .finished)
                }
                guard let data = data, error == nil else {
                    return finish("연결에 실패했어요. AI 서버가 켜져 있는지 확인해 주세요. 🙏")
                }
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                guard let resp = try? decoder.decode(AIChatResponse.self, from: data) else {
                    return finish("응답을 이해하지 못했어요. 다시 시도해 주세요.")
                }
                let out = AIChatRenderer.render(resp.response)
                subject.send(.chunk(out.text))
                if !out.places.isEmpty { subject.send(.attach(places: out.places)) }
                if let rec = out.recommendation { subject.send(.recommendation(rec)) }
                subject.send(.session(resp.session))
                subject.send(.finished)
                subject.send(completion: .finished)
            }
        }
        return subject
            .handleEvents(
                receiveSubscription: { _ in task.resume() },
                receiveCancel: { task.cancel() }
            )
            .eraseToAnyPublisher()
    }
}

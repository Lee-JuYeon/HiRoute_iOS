//
//  ChatRepository.swift
//  HiRoute
//
//  Created by Jupond on 5/20/26.
//

import Foundation
import Combine

/// AI 응답 더미 생성 전용. 대화/메시지 영속화는 ScheduleService가 담당.
final class ChatRepository: ChatProtocol {

    // MARK: - Sample places (dummy attachments)

    private let samplePlaces: [String: PlaceModel] = ChatRepository.makeSamplePlaces()

    private lazy var responsePool: [(text: String, placeKeys: [String])] = [
        (
            """
            어떤 도시를 가시나요? **서울 / 부산 / 제주** 중 알려주세요.
            함께 여행 기간이랑 같이 가는 사람도 알려주시면 좋아요.
            """,
            []
        ),
        (
            """
            ## 추천 3박 4일 서울 일정

            - **Day 1** 경복궁 → 북촌한옥마을 → 광장시장
            - **Day 2** 홍대 → 한강 → 이태원
            - **Day 3** 명동 → N서울타워 → 동대문 야시장
            - **Day 4** 성수동 카페투어 → 인천공항

            대표 장소 몇 곳 먼저 보여드릴게요.
            """,
            ["gyeongbokgung", "bukchon", "gwangjang"]
        ),
        (
            """
            예산을 알려주시면 **숙소/식사/이동** 비용까지 맞춰서 짜드릴게요.
            대략 1인당 80만원 / 150만원 / 자유 중 어느 쪽이신가요?
            """,
            []
        ),
        (
            """
            혼자 여행이시라면 *안전한 동선* 위주로 짜드릴게요.
            어느 동네 분위기 좋아하세요?

            - 조용한 골목 (북촌, 서촌)
            - 트렌디한 거리 (성수, 연남)
            - 사람 많은 번화가 (홍대, 강남)
            """,
            []
        ),
        (
            """
            ## K-드라마 촬영지 코스 (1일)

            - 09:00 **경복궁** — 사극 단골 로케이션
            - 11:30 **북촌한옥마을** — `이상한 변호사 우영우` 등 다수
            - 14:00 **남산타워** — 로맨스 클래식
            - 17:00 **이태원** — `이태원 클라쓰`

            아래 카드를 눌러 상세 정보 확인하세요.
            """,
            ["gyeongbokgung", "bukchon", "namsan"]
        )
    ]

    init() {
        print("ChatRepository, init // Success")
    }

    // MARK: - Streaming (dummy)

    func streamAssistantReply(for userMessage: ChatMessageModel,
                              session: AIChatSession) -> AnyPublisher<ChatStreamEvent, Never> {
        let reply = responsePool.randomElement() ?? (text: "...", placeKeys: [])
        let attachedPlaces = reply.placeKeys.compactMap { samplePlaces[$0] }
        let subject = PassthroughSubject<ChatStreamEvent, Never>()
        let session = ChatStreamingSession(response: reply.text, attachedPlaces: attachedPlaces, subject: subject)
        return subject
            .handleEvents(
                receiveSubscription: { _ in session.start() },
                receiveCancel: { session.cancel() }
            )
            .eraseToAnyPublisher()
    }

    // MARK: - Sample data

    private static func makeSamplePlaces() -> [String: PlaceModel] {
        return [
            "gyeongbokgung": PlaceModel(
                uid: "sample_gyeongbokgung",
                address: AddressModel(
                    uid: "addr_gp",
                    lat: 37.579617, lon: 126.977041,
                    addressTitle: "경복궁",
                    addressBlock1: "서울특별시", addressBlock2: "종로구", addressBlock3: nil,
                    fullAddress: "서울특별시 종로구 사직로 161"
                ),
                type: .landmark,
                title: "경복궁",
                subtitle: "조선시대 정궁",
                thumbnailImage: ImageModel(id: "img_gp", imageUrl: "https://picsum.photos/seed/gyeongbokgung/600/300")
            ),
            "bukchon": PlaceModel(
                uid: "sample_bukchon",
                address: AddressModel(
                    uid: "addr_bc",
                    lat: 37.582574, lon: 126.983796,
                    addressTitle: "북촌한옥마을",
                    addressBlock1: "서울특별시", addressBlock2: "종로구", addressBlock3: nil,
                    fullAddress: "서울특별시 종로구 계동길 37"
                ),
                type: .landmark,
                title: "북촌한옥마을",
                subtitle: "전통 한옥이 모인 골목",
                thumbnailImage: ImageModel(id: "img_bc", imageUrl: "https://picsum.photos/seed/bukchon/600/300")
            ),
            "gwangjang": PlaceModel(
                uid: "sample_gwangjang",
                address: AddressModel(
                    uid: "addr_gwj",
                    lat: 37.570206, lon: 127.000045,
                    addressTitle: "광장시장",
                    addressBlock1: "서울특별시", addressBlock2: "종로구", addressBlock3: nil,
                    fullAddress: "서울특별시 종로구 창경궁로 88"
                ),
                type: .restaurant,
                title: "광장시장",
                subtitle: "전통시장 먹거리 천국",
                thumbnailImage: ImageModel(id: "img_gwj", imageUrl: "https://picsum.photos/seed/gwangjang/600/300")
            ),
            "namsan": PlaceModel(
                uid: "sample_namsan",
                address: AddressModel(
                    uid: "addr_ns",
                    lat: 37.551169, lon: 126.988227,
                    addressTitle: "N서울타워",
                    addressBlock1: "서울특별시", addressBlock2: "용산구", addressBlock3: nil,
                    fullAddress: "서울특별시 용산구 남산공원길 105"
                ),
                type: .landmark,
                title: "N서울타워",
                subtitle: "서울 야경 명소",
                thumbnailImage: ImageModel(id: "img_ns", imageUrl: "https://picsum.photos/seed/namsan/600/300")
            )
        ]
    }
}

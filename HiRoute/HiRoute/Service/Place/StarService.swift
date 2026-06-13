//
//  StarService.swift
//  HiRoute
//
//  Created by Jupond on 11/26/25.
//
import Combine

class StarService {
    private let starProtocol: StarProtocol
    private var cancellables = Set<AnyCancellable>()

    init(starProtocol: StarProtocol) {
        self.starProtocol = starProtocol
    }

    // 별점 주기
    func createRate(placeUid: String, userUid: String, star: Int) -> AnyPublisher<StarModel, Error> {
        starProtocol.createRate(placeUid: placeUid, userUid: userUid, star: star)
            .handleEvents(receiveOutput: { [weak self] _ in
                print("⭐ Rating created: \(placeUid) - \(star) stars")
            })
            .eraseToAnyPublisher()
    }

    // 별점 취소
    func removeRate(placeUid: String, userUid: String) -> AnyPublisher<Void, Error> {
        starProtocol.removeRate(placeUid: placeUid, userUid: userUid)
            .handleEvents(receiveOutput: { [weak self] _ in
                print("⭐ Rating removed: \(placeUid)")
            })
            .eraseToAnyPublisher()
    }

    // 평균 별점
    func readAverageRate(placeUid: String) -> AnyPublisher<Double, Error> {
        starProtocol.readAverageRate(placeUid: placeUid)
    }

    // 내가 평가한 별점 리스트
    func readMyRateList(placeUid: String, userUid: String) -> AnyPublisher<Int?, Error> {
        starProtocol.readMyRateList(placeUid: placeUid, userUid: userUid)
    }

    deinit {
        print("✅ StarService deinit")
    }
}

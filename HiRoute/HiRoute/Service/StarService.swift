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
    func createRate(placeUID: String, userUID: String, star: Int) -> AnyPublisher<StarModel, Error> {
        starProtocol.createRate(placeUID: placeUID, userUID: userUID, star: star)
            .handleEvents(receiveOutput: { [weak self] _ in
                print("⭐ Rating created: \(placeUID) - \(star) stars")
            })
            .eraseToAnyPublisher()
    }
    
    // 별점 취소
    func removeRate(placeUID: String, userUID: String) -> AnyPublisher<Void, Error> {
        starProtocol.removeRate(placeUID: placeUID, userUID: userUID)
            .handleEvents(receiveOutput: { [weak self] _ in
                print("⭐ Rating removed: \(placeUID)")
            })
            .eraseToAnyPublisher()
    }
    
    // 평균 별점
    func readAverageRate(placeUID: String) -> AnyPublisher<Double, Error> {
        starProtocol.readAverageRate(placeUID: placeUID)
    }
    
    // 내가 평가한 별점 리스트
    func readMyRateList(placeUID: String, userUID: String) -> AnyPublisher<Int?, Error> {
        starProtocol.readMyRateList(placeUID: placeUID, userUID: userUID)
    }
    
    // 🚀 Service만의 추가 기능들
    func getRatingStatistics(placeUID: String) -> AnyPublisher<RatingStatistics, Error> {
        readAverageRate(placeUID: placeUID)
            .map { averageRating in
                RatingStatistics(
                    placeUID: placeUID,
                    averageRating: averageRating,
                    totalRatings: Int.random(in: 10...100), // 실제로는 Repository에서 가져와야 함
                    distribution: [
                        5: Int.random(in: 20...50),
                        4: Int.random(in: 15...30),
                        3: Int.random(in: 5...15),
                        2: Int.random(in: 2...8),
                        1: Int.random(in: 1...5)
                    ]
                )
            }
            .eraseToAnyPublisher()
    }
    
    // ✅ deinit 추가 (메모리 해제 확인)
    deinit {
        print("✅ StarService deinit")
    }
}


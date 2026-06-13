//
//  StarRepository.swift
//  HiRoute
//
//  Created by Jupond on 11/26/25.
//
import Foundation
import Combine

private struct StarBody: Encodable {
    let star: Int
}

private struct StarUpsertResponse: Decodable {
    let star: Int
    let isNew: Bool
}

private struct StarDeleteResponse: Decodable {
    let deleted: Bool
}

private struct UserStarResponse: Decodable {
    let star: Int?
}

class StarRepository: StarProtocol {
    
    private var cache = NSCache<NSString, AnyObject>()


    func createRate(placeUid: String, userUid: String, star: Int) -> AnyPublisher<StarModel, Error> {
        let publisher: AnyPublisher<APIResponse<StarUpsertResponse>, Error> =
            APIClient.shared.postWithAuth(path: "/api/places/\(placeUid)/star", body: StarBody(star: star))

        return publisher
            .map { response in
                StarModel(userUid: userUid, star: response.data.star)
            }
            .eraseToAnyPublisher()
    }
    
    func removeRate(placeUid: String, userUid: String) -> AnyPublisher<Void, Error> {
        let publisher: AnyPublisher<APIResponse<StarDeleteResponse>, Error> =
            APIClient.shared.deleteWithAuth(path: "/api/places/\(placeUid)/star")

        return publisher
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    func readAverageRate(placeUid: String) -> AnyPublisher<Double, Error> {
        let diskCacheKey = "star_avg_\(placeUid)"

        let publisher: AnyPublisher<APIResponse<StarStatsDTO>, Error> =
            APIClient.shared.get(path: "/api/places/\(placeUid)/stars")

        return publisher
            .map { response in response.data.average ?? 0.0 }
            .handleEvents(receiveOutput: { average in
                JsonFileCache.shared.save(average, forKey: diskCacheKey)
            })
            .catch { error -> AnyPublisher<Double, Error> in
                if let cached: Double = JsonFileCache.shared.load(forKey: diskCacheKey) {
                    return Just(cached).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func readMyRateList(placeUid: String, userUid: String) -> AnyPublisher<Int?, Error> {
        let publisher: AnyPublisher<APIResponse<UserStarResponse>, Error> =
            APIClient.shared.getWithAuth(path: "/api/places/\(placeUid)/star/me")

        return publisher
            .map { response in
                response.data.star
            }
            .eraseToAnyPublisher()
    }
}

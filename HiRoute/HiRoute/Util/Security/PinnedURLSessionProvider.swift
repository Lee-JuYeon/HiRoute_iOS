//
//  PinnedURLSessionProvider.swift
//  HiRoute
//
//  첫-파티(api.nunulala.com) 호출용 핀된 URLSession 공급자.
//  URLSession.shared는 delegate를 가질 수 없어 TLS pinning이 불가하므로,
//  CertificatePinner를 delegate로 물린 전용 세션을 vending한다.
//  - streamingSession: AI 챗 등 장기/스트리밍 요청용(120s).
//  - imageSession: 첫-파티 이미지 GET 등 일반 요청용.
//  서드파티 CDN 호출은 핀과 불일치하여 거부되므로 이 세션을 쓰면 안 된다(isFirstParty로 판별).
//
import Foundation

final class PinnedURLSessionProvider {

    static let shared = PinnedURLSessionProvider()

    /// 핀 delegate. URLSession이 delegate를 강하게 잡으므로 세션 수명 동안 유지된다.
    private let pinner = CertificatePinner()

    /// 장기/스트리밍 요청용(예: AI 챗 120s 타임아웃).
    let streamingSession: URLSession

    /// 첫-파티 이미지 등 일반 GET용.
    let imageSession: URLSession

    private init() {
        let streamConfig = URLSessionConfiguration.default
        streamConfig.timeoutIntervalForRequest = 120
        streamConfig.timeoutIntervalForResource = 120
        streamingSession = URLSession(configuration: streamConfig, delegate: pinner, delegateQueue: nil)

        let imageConfig = URLSessionConfiguration.default
        imageConfig.timeoutIntervalForRequest = 30
        imageConfig.timeoutIntervalForResource = 60
        imageConfig.requestCachePolicy = .returnCacheDataElseLoad
        imageSession = URLSession(configuration: imageConfig, delegate: pinner, delegateQueue: nil)
    }

    /// 첫-파티(api.nunulala.com) 호스트 여부. 핀 대상이므로 이 경우에만 핀된 세션을 사용한다.
    static func isFirstParty(_ url: URL?) -> Bool {
        guard let host = url?.host?.lowercased() else { return false }
        return host == firstPartyHost
    }

    private static let firstPartyHost: String = {
        URL(string: SecretKeys.apiBaseURL)?.host?.lowercased() ?? "api.nunulala.com"
    }()
}

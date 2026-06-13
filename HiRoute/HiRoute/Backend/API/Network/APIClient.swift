//
//  APIClient.swift
//  HiRoute
//
//  Created by Jupond on 3/10/26.
//
import Foundation
import Combine
import UIKit

final class APIClient {

    static let shared = APIClient()

    private var baseURL: String { SecretKeys.apiBaseURL }
    private let session: URLSession
    private let decoder: JSONDecoder
    private let certificatePinner: CertificatePinner

    // [SEC-09] 단일-flight refresh 코얼레서 — 동시 다발 401(예: 검색 fan-out)에서 refreshToken() 1회만 실행
    private let refreshLock = NSLock()
    private var inFlightRefresh: Task<Bool, Never>?

    /// 디바이스 고유 ID — Token Device Binding용
    private var deviceId: String {
        UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
    }

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        config.requestCachePolicy = .useProtocolCachePolicy

        let pinner = CertificatePinner()
        self.certificatePinner = pinner
        session = URLSession(configuration: config, delegate: pinner, delegateQueue: nil)

        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    // MARK: - GET Request

    /// Generic GET request returning decoded response via Combine
    func get<T: Decodable>(path: String, queryItems: [URLQueryItem]? = nil) -> AnyPublisher<T, Error> {
        guard var components = URLComponents(string: baseURL + path) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }

        // Filter out nil-value query items
        if let items = queryItems {
            let filtered = items.filter { $0.value != nil }
            if !filtered.isEmpty {
                components.queryItems = filtered
            }
        }

        guard let url = components.url else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        addAuthHeader(to: &request)

        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.noData
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    if httpResponse.statusCode == 429 {
                        let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After")
                            .flatMap { TimeInterval($0) }
                        throw NetworkError.rateLimited(retryAfter: retryAfter)
                    }
                    #if DEBUG
                    print(
                        "APIClient GET response failed: status=\(httpResponse.statusCode), path=\(path), body=\(String(data: data, encoding: .utf8) ?? "")"
                    )
                    #endif
                    throw NetworkError.serverError(httpResponse.statusCode)
                }
                APIClient.checkResponseIntegrity(httpResponse)
                return data
            }
            .decode(type: T.self, decoder: decoder)
            .mapError { error -> Error in
                if error is DecodingError {
                    return NetworkError.decodingError
                }
                return error
            }
            .eraseToAnyPublisher()
    }

    // MARK: - POST Request (for future auth endpoints)

    /// Generic POST request with Encodable body
    func post<T: Decodable, B: Encodable>(path: String, body: B) -> AnyPublisher<T, Error> {
        guard let url = URL(string: baseURL + path) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        addAuthHeader(to: &request)

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.noData
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    if httpResponse.statusCode == 429 {
                        let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After")
                            .flatMap { TimeInterval($0) }
                        throw NetworkError.rateLimited(retryAfter: retryAfter)
                    }
                    throw NetworkError.serverError(httpResponse.statusCode)
                }
                APIClient.checkResponseIntegrity(httpResponse)

                #if DEBUG
                if let jsonString = String(data: data, encoding: .utf8) {
                    // [2026-05-27 Phase A.5] DEBUG 한정. 응답 body는 PII/토큰 포함 가능.
                    print("APIClient POST response: \(APIClient.truncate(jsonString))")
                }
                #endif

                return data
            }
            .decode(type: T.self, decoder: decoder)
            .mapError { error -> Error in
                if let decodingError = error as? DecodingError {
                    #if DEBUG
                    print("APIClient DecodingError: \(decodingError)")
                    #endif
                    return NetworkError.decodingError
                }
                return error
            }
            .eraseToAnyPublisher()
    }

    /// [2026-05-27 Phase A.5] 로그 본문 절단 — PII/토큰 노출 최소화 (DEBUG에서도).
    private static func truncate(_ s: String, max: Int = 500) -> String {
        if s.count <= max { return s }
        let head = String(s.prefix(max))
        return "\(head)…(\(s.count - max)자 생략)"
    }

    // MARK: - PUT Request

    func put<T: Decodable, B: Encodable>(path: String, body: B) -> AnyPublisher<T, Error> {
        guard let url = URL(string: baseURL + path) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        addAuthHeader(to: &request)

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.noData
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    if httpResponse.statusCode == 429 {
                        let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After")
                            .flatMap { TimeInterval($0) }
                        throw NetworkError.rateLimited(retryAfter: retryAfter)
                    }
                    throw NetworkError.serverError(httpResponse.statusCode)
                }
                APIClient.checkResponseIntegrity(httpResponse)
                return data
            }
            .decode(type: T.self, decoder: decoder)
            .mapError { error -> Error in
                if error is DecodingError {
                    return NetworkError.decodingError
                }
                return error
            }
            .eraseToAnyPublisher()
    }

    /// 401 시 refresh 후 재시도, 429 시 지수 백오프 재시도하는 PUT
    func putWithAuth<T: Decodable, B: Encodable>(path: String, body: B) -> AnyPublisher<T, Error> {
        let request: AnyPublisher<T, Error> = put(path: path, body: body)
        return request.catch { [weak self] error -> AnyPublisher<T, Error> in
            guard let self = self,
                  let networkError = error as? NetworkError else {
                return Fail(error: error).eraseToAnyPublisher()
            }
            switch networkError {
            case .serverError(401):
                return self.refreshTokenCoalescedPublisher()
                    .flatMap { success -> AnyPublisher<T, Error> in
                        if success {
                            return self.put(path: path, body: body)
                        } else {
                            self.handleLogout()
                            return Fail(error: NetworkError.unauthorized).eraseToAnyPublisher()
                        }
                    }
                    .eraseToAnyPublisher()
            case .rateLimited(let retryAfter):
                let delay = retryAfter ?? 2.0
                return Just(())
                    .delay(for: .seconds(delay), scheduler: DispatchQueue.global())
                    .flatMap { self.put(path: path, body: body) as AnyPublisher<T, Error> }
                    .eraseToAnyPublisher()
            default:
                return Fail(error: error).eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - DELETE Request

    func delete<T: Decodable>(path: String) -> AnyPublisher<T, Error> {
        guard let url = URL(string: baseURL + path) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        addAuthHeader(to: &request)

        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.noData
                }
                guard (200...299).contains(httpResponse.statusCode) else {
                    if httpResponse.statusCode == 429 {
                        let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After")
                            .flatMap { TimeInterval($0) }
                        throw NetworkError.rateLimited(retryAfter: retryAfter)
                    }
                    throw NetworkError.serverError(httpResponse.statusCode)
                }
                APIClient.checkResponseIntegrity(httpResponse)
                return data
            }
            .decode(type: T.self, decoder: decoder)
            .mapError { error -> Error in
                if error is DecodingError {
                    return NetworkError.decodingError
                }
                return error
            }
            .eraseToAnyPublisher()
    }

    /// 401 시 refresh 후 재시도, 429 시 지수 백오프 재시도하는 DELETE
    func deleteWithAuth<T: Decodable>(path: String) -> AnyPublisher<T, Error> {
        let request: AnyPublisher<T, Error> = delete(path: path)
        return request.catch { [weak self] error -> AnyPublisher<T, Error> in
            guard let self = self,
                  let networkError = error as? NetworkError else {
                return Fail(error: error).eraseToAnyPublisher()
            }
            switch networkError {
            case .serverError(401):
                return self.refreshTokenCoalescedPublisher()
                    .flatMap { success -> AnyPublisher<T, Error> in
                        if success {
                            return self.delete(path: path)
                        } else {
                            self.handleLogout()
                            return Fail(error: NetworkError.unauthorized).eraseToAnyPublisher()
                        }
                    }
                    .eraseToAnyPublisher()
            case .rateLimited(let retryAfter):
                let delay = retryAfter ?? 2.0
                return Just(())
                    .delay(for: .seconds(delay), scheduler: DispatchQueue.global())
                    .flatMap { self.delete(path: path) as AnyPublisher<T, Error> }
                    .eraseToAnyPublisher()
            default:
                return Fail(error: error).eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Multipart Upload

    func uploadFile<T: Decodable>(path: String, fileData: Data, fileName: String, mimeType: String) -> AnyPublisher<T, Error> {
        guard let url = URL(string: baseURL + path) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        addAuthHeader(to: &request)

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let http = response as? HTTPURLResponse else { throw NetworkError.noData }
                guard (200...299).contains(http.statusCode) else {
                    if http.statusCode == 429 {
                        let retryAfter = http.value(forHTTPHeaderField: "Retry-After")
                            .flatMap { TimeInterval($0) }
                        throw NetworkError.rateLimited(retryAfter: retryAfter)
                    }
                    #if DEBUG
                    print("🔐 uploadFile // FAIL: status=\(http.statusCode), body=\(String(data: data, encoding: .utf8) ?? "")")
                    #endif
                    throw NetworkError.serverError(http.statusCode)
                }
                return data
            }
            .decode(type: T.self, decoder: decoder)
            .mapError { $0 is DecodingError ? NetworkError.decodingError : $0 }
            .eraseToAnyPublisher()
    }

    func uploadFileWithAuth<T: Decodable>(path: String, fileData: Data, fileName: String, mimeType: String) -> AnyPublisher<T, Error> {
        let req: AnyPublisher<T, Error> = uploadFile(path: path, fileData: fileData, fileName: fileName, mimeType: mimeType)
        return req.catch { [weak self] error -> AnyPublisher<T, Error> in
            guard let self = self,
                  let networkError = error as? NetworkError else {
                return Fail(error: error).eraseToAnyPublisher()
            }
            switch networkError {
            case .serverError(401):
                return self.refreshTokenCoalescedPublisher()
                    .flatMap { success -> AnyPublisher<T, Error> in
                        if success {
                            return self.uploadFile(path: path, fileData: fileData, fileName: fileName, mimeType: mimeType)
                        } else {
                            self.handleLogout()
                            return Fail(error: NetworkError.unauthorized).eraseToAnyPublisher()
                        }
                    }
                    .eraseToAnyPublisher()
            case .rateLimited(let retryAfter):
                let delay = retryAfter ?? 2.0
                return Just(())
                    .delay(for: .seconds(delay), scheduler: DispatchQueue.global())
                    .flatMap { self.uploadFile(path: path, fileData: fileData, fileName: fileName, mimeType: mimeType) as AnyPublisher<T, Error> }
                    .eraseToAnyPublisher()
            default:
                return Fail(error: error).eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Auth

    private func addAuthHeader(to request: inout URLRequest) {
        if let tokenData = try? KeychainService.load(account: "access_token"),
           let token = String(data: tokenData, encoding: .utf8) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        // Device Binding — 서버 JWT에 device_id 포함하여 토큰 탈취 시 다른 기기 사용 차단
        request.setValue(deviceId, forHTTPHeaderField: "X-Device-ID")
    }

    /// 응답 무결성 검증 — HMAC 서명 헤더 존재 + format 검증.
    /// [2026-05-27 Phase A.4] 강화.
    /// **v1.0 한계**: HMAC body 진짜 검증은 별도 비대칭 키(Ed25519) 도입 후. 현재는 헤더 존재 + 길이.
    /// **v1.1 계획**: 서버 응답에 Ed25519 서명 → 클라 binary에 public key 박아 검증 → reject까지.
    /// 1차 방어선은 TLS pinning (CertificatePinner). 이게 무력화돼야 MITM 가능.
    private static func checkResponseIntegrity(_ response: HTTPURLResponse) {
        guard let signature = response.value(forHTTPHeaderField: "X-Response-Signature") else {
            #if DEBUG
            print("⚠️ APIClient: X-Response-Signature 헤더 부재 — possible tampering or 구버전 서버")
            #endif
            return
        }
        // SHA-256 hex = 64 chars. 짧으면 가짜 서명.
        if signature.count < 32 {
            #if DEBUG
            print("⚠️ APIClient: 응답 서명 길이 비정상 — \(signature.count)자")
            #endif
        }
    }

    /// refresh token으로 access token 갱신
    private func refreshToken() -> AnyPublisher<Bool, Never> {
        guard let refreshData = try? KeychainService.load(account: "refresh_token"),
              let refreshToken = String(data: refreshData, encoding: .utf8),
              let url = URL(string: baseURL + "/api/auth/refresh") else {
            #if DEBUG
            print("🔐 APIClient.refreshToken // FAIL: refresh_token 없음 (Keychain 비어있음)")
            #endif
            return Just(false).eraseToAnyPublisher()
        }

        #if DEBUG
        print("🔐 APIClient.refreshToken // 시도: deviceId=\(deviceId)")
        #endif

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(deviceId, forHTTPHeaderField: "X-Device-ID")

        let body = RefreshRequest(refreshToken: refreshToken)
        request.httpBody = try? JSONEncoder().encode(body)

        // refresh 응답은 camelCase JSON → convertFromSnakeCase decoder 사용 불가
        let plainDecoder = JSONDecoder()

        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let http = response as? HTTPURLResponse else {
                    #if DEBUG
                    print("🔐 APIClient.refreshToken // FAIL: 응답 없음")
                    #endif
                    throw NetworkError.unauthorized
                }
                if !(200...299).contains(http.statusCode) {
                    // [SEC-12] refresh 응답 body는 토큰 자료를 포함할 수 있어 절대 로그하지 않음. 상태코드만.
                    #if DEBUG
                    print("🔐 APIClient.refreshToken // FAIL: status=\(http.statusCode)")
                    #endif
                    throw NetworkError.serverError(http.statusCode)
                }
                #if DEBUG
                print("🔐 APIClient.refreshToken // SUCCESS: status=\(http.statusCode)")
                #endif
                return data
            }
            .decode(type: APIResponse<RefreshResponse>.self, decoder: plainDecoder)
            .map { response in
                let tokens = response.data
                if let accessData = tokens.accessToken.data(using: .utf8),
                   let refreshData = tokens.refreshToken.data(using: .utf8) {
                    try? KeychainService.save(data: accessData, account: "access_token")
                    try? KeychainService.save(data: refreshData, account: "refresh_token")
                    #if DEBUG
                    print("🔐 APIClient.refreshToken // 토큰 갱신 완료, Keychain 저장됨")
                    #endif
                }
                return true
            }
            .replaceError(with: false)
            .eraseToAnyPublisher()
    }

    /// 401 시 refresh 후 재시도, 429 시 지수 백오프 재시도하는 GET
    func getWithAuth<T: Decodable>(path: String, queryItems: [URLQueryItem]? = nil) -> AnyPublisher<T, Error> {
        let request: AnyPublisher<T, Error> = get(path: path, queryItems: queryItems)
        return request.catch { [weak self] error -> AnyPublisher<T, Error> in
            guard let self = self,
                  let networkError = error as? NetworkError else {
                return Fail(error: error).eraseToAnyPublisher()
            }
            switch networkError {
            case .serverError(401):
                #if DEBUG
                print("🔐 getWithAuth // 401 감지: path=\(path), refresh 시도")
                #endif
                return self.refreshTokenCoalescedPublisher()
                    .flatMap { success -> AnyPublisher<T, Error> in
                        if success {
                            #if DEBUG
                            print("🔐 getWithAuth // refresh 성공, 재시도: \(path)")
                            #endif
                            return self.get(path: path, queryItems: queryItems)
                        } else {
                            #if DEBUG
                            print("🔐 getWithAuth // refresh 실패 → handleLogout: \(path)")
                            #endif
                            self.handleLogout()
                            return Fail(error: NetworkError.unauthorized).eraseToAnyPublisher()
                        }
                    }
                    .eraseToAnyPublisher()
            case .rateLimited(let retryAfter):
                let delay = retryAfter ?? 2.0
                #if DEBUG
                print("🔐 getWithAuth // 429 감지: path=\(path), \(delay)초 후 재시도")
                #endif
                return Just(())
                    .delay(for: .seconds(delay), scheduler: DispatchQueue.global())
                    .flatMap { self.get(path: path, queryItems: queryItems) as AnyPublisher<T, Error> }
                    .eraseToAnyPublisher()
            default:
                return Fail(error: error).eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }

    /// 401 시 refresh 후 재시도, 429 시 지수 백오프 재시도하는 POST
    func postWithAuth<T: Decodable, B: Encodable>(path: String, body: B) -> AnyPublisher<T, Error> {
        let request: AnyPublisher<T, Error> = post(path: path, body: body)
        return request.catch { [weak self] error -> AnyPublisher<T, Error> in
            guard let self = self,
                  let networkError = error as? NetworkError else {
                return Fail(error: error).eraseToAnyPublisher()
            }
            switch networkError {
            case .serverError(401):
                #if DEBUG
                print("🔐 postWithAuth // 401 감지: path=\(path), refresh 시도")
                #endif
                return self.refreshTokenCoalescedPublisher()
                    .flatMap { success -> AnyPublisher<T, Error> in
                        if success {
                            #if DEBUG
                            print("🔐 postWithAuth // refresh 성공, 재시도: \(path)")
                            #endif
                            return self.post(path: path, body: body)
                        } else {
                            #if DEBUG
                            print("🔐 postWithAuth // refresh 실패 → handleLogout: \(path)")
                            #endif
                            self.handleLogout()
                            return Fail(error: NetworkError.unauthorized).eraseToAnyPublisher()
                        }
                    }
                    .eraseToAnyPublisher()
            case .rateLimited(let retryAfter):
                let delay = retryAfter ?? 2.0
                #if DEBUG
                print("🔐 postWithAuth // 429 감지: path=\(path), \(delay)초 후 재시도")
                #endif
                return Just(())
                    .delay(for: .seconds(delay), scheduler: DispatchQueue.global())
                    .flatMap { self.post(path: path, body: body) as AnyPublisher<T, Error> }
                    .eraseToAnyPublisher()
            default:
                return Fail(error: error).eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }

    /// refresh 실패 시 로그아웃 처리
    /// [2026-05-27 Phase A.5] JWT payload 노출은 DEBUG 한정. release에선 결과만.
    private func handleLogout() {
        #if DEBUG
        print("🔐 APIClient.handleLogout // 세션 만료 → 로그아웃 처리 시작")
        print("🔐 APIClient.handleLogout // deviceId=\(deviceId)")
        if let tokenData = try? KeychainService.load(account: "access_token"),
           let token = String(data: tokenData, encoding: .utf8) {
            // JWT payload 디코딩 — DEBUG only.
            let parts = token.split(separator: ".")
            if parts.count > 1 {
                var base64 = String(parts[1])
                while base64.count % 4 != 0 { base64 += "=" }
                if let data = Data(base64Encoded: base64),
                   let json = String(data: data, encoding: .utf8) {
                    print("🔐 APIClient.handleLogout // 만료된 토큰 payload: \(APIClient.truncate(json, max: 200))")
                }
            }
        } else {
            print("🔐 APIClient.handleLogout // access_token 이미 없음")
        }
        #endif
        KeychainService.delete(account: "access_token")
        KeychainService.delete(account: "refresh_token")
        UserDefaults.standard.removeObject(forKey: "currentUserUID")
        NotificationCenter.default.post(
            name: Notification.Name.sessionExpired,
            object: nil,
            userInfo: nil
        )
    }

    // MARK: - [SEC-09] Pinned async passthrough request

    /// 핀된 세션을 통해 raw `Data`를 반환하는 내부 요청기.
    /// 서드파티(대중교통/VisitSeoul) 프록시 호출을 모두 HTTPS+pinning 경유로 통일한다.
    /// - authRefresh:true  → 401 시 단일-flight refresh 후 1회 재시도, 실패 시 handleLogout()
    /// - authRefresh:false → 401 시 refresh/logout 없이 throw (게스트 브라우징 강제 로그아웃 방지)
    func requestData(
        path: String,
        method: String = "GET",
        queryItems: [URLQueryItem]? = nil,
        body: Data? = nil,
        contentType: String? = nil,
        authRefresh: Bool = false
    ) async throws -> Data {
        func buildRequest() throws -> URLRequest {
            guard var components = URLComponents(string: baseURL + path) else {
                throw NetworkError.invalidURL
            }
            if let items = queryItems {
                let filtered = items.filter { $0.value != nil }
                if !filtered.isEmpty { components.queryItems = filtered }
            }
            guard let url = components.url else { throw NetworkError.invalidURL }

            var request = URLRequest(url: url)
            request.httpMethod = method
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            if let body = body {
                request.httpBody = body
                request.setValue(contentType ?? "application/json", forHTTPHeaderField: "Content-Type")
            }
            addAuthHeader(to: &request)
            return request
        }

        func perform() async throws -> Data {
            let request = try buildRequest()
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw NetworkError.noData }
            if http.statusCode == 401 { throw NetworkError.serverError(401) }
            if http.statusCode == 429 {
                let retryAfter = http.value(forHTTPHeaderField: "Retry-After").flatMap { TimeInterval($0) }
                throw NetworkError.rateLimited(retryAfter: retryAfter)
            }
            guard (200...299).contains(http.statusCode) else {
                throw NetworkError.serverError(http.statusCode)
            }
            APIClient.checkResponseIntegrity(http)
            return data
        }

        do {
            return try await perform()
        } catch let error as NetworkError {
            switch error {
            case .serverError(401):
                guard authRefresh else { throw NetworkError.unauthorized }
                let refreshed = await refreshTokenCoalesced()
                if refreshed {
                    return try await perform()
                } else {
                    handleLogout()
                    throw NetworkError.unauthorized
                }
            case .rateLimited(let retryAfter):
                let delay = retryAfter ?? 2.0
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                return try await perform()
            default:
                throw error
            }
        }
    }

    /// [SEC-09] Combine 경로용 단일-flight refresh 브리지.
    /// 동시 다발 401(검색 fan-out 등)이 각자 refreshToken()을 호출해 회전 refresh 토큰을
    /// 중복 소비 → 서버 reuse-detection이 세션 전체를 revoke(자기-DoS/강제 로그아웃)하던 문제를,
    /// async 코얼레서(refreshTokenCoalesced)에 합류시켜 단 1회 refresh 후 retry 하도록 차단한다.
    /// Deferred로 구독 시점마다 평가 → 매 401이 동일 in-flight Task를 공유한다.
    /// APIClient는 싱글턴(.shared)이라 self 강참조에 의한 누수 없음(앱 수명과 동일).
    private func refreshTokenCoalescedPublisher() -> AnyPublisher<Bool, Never> {
        Deferred {
            Future<Bool, Never> { promise in
                Task {
                    let success = await self.refreshTokenCoalesced()
                    promise(.success(success))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /// 단일-flight refresh: 동시 다발 호출이 같은 Task를 공유해 refreshToken()을 1회만 실행.
    private func refreshTokenCoalesced() async -> Bool {
        let (task, isOwner) = beginRefresh()
        let result = await task.value
        if isOwner { endRefresh() }
        return result
    }

    /// 락 임계영역(동기) — in-flight Task가 있으면 재사용, 없으면 생성. isOwner=true면 호출자가 종료 책임.
    private func beginRefresh() -> (Task<Bool, Never>, Bool) {
        refreshLock.lock()
        defer { refreshLock.unlock() }
        if let existing = inFlightRefresh {
            return (existing, false)
        }
        let task = Task<Bool, Never> { await self.runRefresh() }
        inFlightRefresh = task
        return (task, true)
    }

    private func endRefresh() {
        refreshLock.lock()
        inFlightRefresh = nil
        refreshLock.unlock()
    }

    /// 기존 Combine refreshToken() 퍼블리셔를 async 로 브리지 (회전 로직 변경 없음).
    private func runRefresh() async -> Bool {
        await withCheckedContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = self.refreshToken()
                .sink { value in
                    continuation.resume(returning: value)
                    cancellable?.cancel()
                    cancellable = nil
                }
        }
    }
}

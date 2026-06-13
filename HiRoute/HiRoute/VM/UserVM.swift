//
//  UserVM.swift
//  HiRoute
//
//  Created by Jupond on 3/1/26.
//

import Combine
import SwiftUI

private struct UserProfileBody: Encodable {
    let name: String
    let nationality: String
    let gender: String
    let age: Int?
}

private struct UserProfileResponse: Decodable {
    let uid: String
}

class UserVM: ObservableObject {

    // MARK: - Published Properties
    @Published var currentUser: UserModel?

    // MARK: - Dependencies
    private let userService: UserService
    private var cancellables = Set<AnyCancellable>()

    // 회원가입 임시 데이터
    var pendingAgreements: [String: Bool] = [:]

    // Snackbar
    @Published var showSnackBarLoginError: Bool = false

    var currentUserUID: String {
        currentUser?.uid ?? ""
    }
    
    func socialLogin(provider : String, idToken : String, name : String? = nil, rawNonce : String? = nil, completion : @escaping (Bool) -> Void) {
        #if DEBUG
        print("🔍 socialLogin // provider: \(provider), tokenLen: \(idToken.count)")
        #endif
        let body = AuthTokenRequest(provider: provider, token: idToken, name: name, rawNonce: rawNonce)
        let publisher: AnyPublisher<APIResponse<AuthTokenResponse>, Error> = APIClient.shared.post(
            path: "/api/auth/token",
            body: body
        )

        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                if case .failure(let error) = result {
                    print("UserVM, socialLogin // Exception : \(error.localizedDescription)")
                    self?.showSnackBarLoginError = true
                }
            } receiveValue: { [weak self] response in
                let authData = response.data

                // Keychain에 토큰 저장
                if let accessData = authData.accessToken.data(using: .utf8),
                   let refreshData = authData.refreshToken.data(using: .utf8) {
                    try? KeychainService.save(
                        data: accessData,
                        account: "access_token"
                    )
                    try? KeychainService.save(
                        data: refreshData,
                        account: "refresh_token"
                    )
                }

                // 신규 유저 or 프로필 미완성 → register (UID는 프로필 완료 시 저장)
                let needsRegister = authData.user.isNew || authData.user.nationality.isEmpty
                if !needsRegister {
                    UserDefaults.standard.set(authData.user.uid, forKey: "currentUserUID")
                    self?.loadCurrentUser()
                }
                #if DEBUG
                print("🔍 socialLogin // isNew: \(authData.user.isNew), nationality: '\(authData.user.nationality)', needsRegister: \(needsRegister)")
                #endif
                completion(needsRegister)
            }
            .store(in: &self.cancellables)

    }

    // MARK: - Init

    init(userService: UserService) {
        self.userService = userService
        SEKeyManager.handleAppReinstallIfNeeded()
        loadCurrentUser()
    }

    // MARK: - 회원가입 플로우

    /// AgreeView에서 약관 동의 상태 전달
    func setAgreements(_ agreements: [String: Bool]) {
        pendingAgreements = agreements
    }

    /// 약관 동의 서버 전송
    func submitTermConsents(_ termIds: [Int]) {
        guard !termIds.isEmpty else { return }
        let body = TermConsentBody(termIds: termIds)
        let publisher: AnyPublisher<APIResponse<TermConsentResponse>, Error> =
            APIClient.shared.postWithAuth(path: "/api/terms/consent", body: body)

        publisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("UserVM, submitTermConsents // Error: \(error.localizedDescription)")
                }
            }, receiveValue: { response in
                print("UserVM, submitTermConsents // Success: \(response.data.count) consents")
            })
            .store(in: &cancellables)
    }

    /// UserInfoSettingView에서 호출 — 서버 프로필 업데이트 + 로컬 DB 저장
    func createUser(name: String, nationality: String, gender: GenderType, age: Int?, completion: @escaping (Bool) -> Void) {
        let uid = JWTHelper.extractUIDFromKeychain() ?? UUID().uuidString
        let now = Date()
        let user = UserModel(
            uid: uid,
            name: name,
            nationality: nationality,
            gender: gender,
            age: age,
            agreements: UserAgreementModel(
                service: pendingAgreements["service"] ?? false,
                serviceAgreedDate: pendingAgreements["service"] == true ? now : nil,
                privacy: pendingAgreements["privacy"] ?? false,
                privacyAgreedDate: pendingAgreements["privacy"] == true ? now : nil,
                location: pendingAgreements["location"] ?? false,
                locationAgreedDate: pendingAgreements["location"] == true ? now : nil,
                marketing: pendingAgreements["marketing"] ?? false,
                marketingAgreedDate: pendingAgreements["marketing"] == true ? now : nil,
                push: pendingAgreements["push"] ?? false,
                pushAgreedDate: pendingAgreements["push"] == true ? now : nil
            ),
            createdDate: now,
            editDate: now
        )

        // 서버에 프로필 업데이트
        let body = UserProfileBody(name: name, nationality: nationality, gender: gender.rawValue, age: age)
        let serverPublisher: AnyPublisher<APIResponse<UserProfileResponse>, Error> =
            APIClient.shared.putWithAuth(path: "/api/users/\(uid)", body: body)

        serverPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { comp in
                if case .failure(let error) = comp {
                    print("UserVM, createUser // Server sync failed: \(error.localizedDescription)")
                }
            }, receiveValue: { _ in
                print("UserVM, createUser // Server profile updated")
            })
            .store(in: &cancellables)

        // 로컬 DB 저장 — 완료 후 completion 콜백
        userService.create(user)
            .receive(on: DispatchQueue.main)
            .sink { comp in
                if case .failure(let error) = comp {
                    print("UserVM, createUser // Local save failed: \(error.localizedDescription)")
                    completion(false)
                }
            } receiveValue: { [weak self] savedUser in
                self?.currentUser = savedUser
                UserDefaults.standard.set(savedUser.uid, forKey: "currentUserUID")
                self?.pendingAgreements = [:]
                completion(true)
            }
            .store(in: &cancellables)
    }

    // MARK: - 읽기

    /// 앱 시작 시 저장된 사용자 정보 로드.
    /// [2026-05-26 FIX] CoreData destroy fallback이나 OS 데이터 정리 등으로 UserEntity가
    /// 사라졌는데 UserDefaults의 currentUserUID는 남아있는 stale 상황 처리.
    /// `.notFound`면 uid 정리 + currentUser nil로 — UI는 로그아웃 상태로 인식.
    func loadCurrentUser() {
        guard let uid = UserDefaults.standard.string(forKey: "currentUserUID") else { return }

        userService.read(uid: uid)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print("UserVM, loadCurrentUser // Exception : \(error.localizedDescription)")
                    if case UserError.notFound = error {
                        print("UserVM, loadCurrentUser // stale currentUserUID 정리 → 로그아웃 상태 전환")
                        UserDefaults.standard.removeObject(forKey: "currentUserUID")
                        self?.currentUser = nil
                    }
                }
            } receiveValue: { [weak self] user in
                self?.currentUser = user
            }
            .store(in: &cancellables)
    }

    // MARK: - 업데이트

    func updateUser(_ user: UserModel) {
        userService.update(user)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("UserVM, updateUser // Exception : \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] updatedUser in
                self?.currentUser = updatedUser
            }
            .store(in: &cancellables)
    }

    // MARK: - 로그아웃

    /// 로그아웃 — 토큰 + UID 삭제, 메모리 정리
    func logout() {
        currentUser = nil
        KeychainService.delete(account: "access_token")
        KeychainService.delete(account: "refresh_token")
        UserDefaults.standard.removeObject(forKey: "currentUserUID")
    }

    // MARK: - 회원 탈퇴

    /// [2026-05-27 Phase A.6] 회원 탈퇴 — Apple App Store §3.1.5(a) 요건.
    /// 서버: soft delete + 모든 데이터 cascade soft delete + 30일 후 hard delete.
    /// 클라: 로컬 user + 토큰 + UserDefaults 정리. CoreData schedule도 정리.
    func deleteAccount(completion: @escaping (Bool, String?) -> Void) {
        guard let uid = currentUser?.uid ?? UserDefaults.standard.string(forKey: "currentUserUID") else {
            completion(false, "사용자 정보 없음")
            return
        }

        let publisher: AnyPublisher<APIResponse<DeleteAccountResponse>, Error> =
            APIClient.shared.deleteWithAuth(path: "/api/users/\(uid)")

        publisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completionEvent in
                    if case .failure(let error) = completionEvent {
                        #if DEBUG
                        print("UserVM, deleteAccount // 실패: \(error.localizedDescription)")
                        #endif
                        completion(false, error.localizedDescription)
                    }
                    _ = self
                },
                receiveValue: { [weak self] response in
                    #if DEBUG
                    print("UserVM, deleteAccount // 서버 탈퇴 완료: \(response.data.message)")
                    #endif
                    // 로컬 정리
                    guard let self = self else {
                        completion(true, response.data.message)
                        return
                    }
                    self.userService.delete(uid: uid)
                        .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
                        .store(in: &self.cancellables)
                    self.logout()
                    completion(true, response.data.message)
                }
            )
            .store(in: &cancellables)
    }

    deinit {
        cancellables.removeAll()
    }
}

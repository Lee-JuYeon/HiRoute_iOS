//
//  UserService.swift
//  HiRoute
//
//  Created by Jupond on 3/1/26.
//

import Combine
import Foundation

class UserService {

    // MARK: - Dependencies
    private let repository: UserProtocol

    // MARK: - Reactive
    private var cancellables = Set<AnyCancellable>()

    init(repository: UserProtocol) {
        self.repository = repository
    }

    // MARK: - CRUD

    func create(_ user: UserModel) -> AnyPublisher<UserModel, Error> {
        return Just(user)
            .tryMap { [weak self] user in
                try self?.validateUser(user).get()
                return user
            }
            .flatMap { [weak self] validatedUser in
                guard let self = self else {
                    return Fail<UserModel, Error>(error: UserError.unknown)
                        .eraseToAnyPublisher()
                }
                return self.repository.create(validatedUser)
            }
            .eraseToAnyPublisher()
    }

    func read(uid: String) -> AnyPublisher<UserModel, Error> {
        return repository.read(uid: uid)
    }

    func update(_ user: UserModel) -> AnyPublisher<UserModel, Error> {
        return Just(user)
            .tryMap { [weak self] user in
                try self?.validateUser(user).get()
                return user
            }
            .flatMap { [weak self] validatedUser in
                guard let self = self else {
                    return Fail<UserModel, Error>(error: UserError.unknown)
                        .eraseToAnyPublisher()
                }
                return self.repository.update(validatedUser)
            }
            .eraseToAnyPublisher()
    }

    func delete(uid: String) -> AnyPublisher<Void, Error> {
        return repository.delete(uid: uid)
    }

    // MARK: - Validation

    /// 필수 약관 동의 여부 + 이름 비어있지 않은지 검증
    private func validateUser(_ user: UserModel) -> Result<Void, UserError> {
        if user.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .failure(.validationFailed("이름이 비어있습니다"))
        }
        if !user.agreements.service {
            return .failure(.validationFailed("서비스 이용약관 동의 필요"))
        }
        if !user.agreements.privacy {
            return .failure(.validationFailed("개인정보 수집 및 이용 동의 필요"))
        }
        if !user.agreements.location {
            return .failure(.validationFailed("위치기반 서비스 동의 필요"))
        }
        return .success(())
    }

    deinit {
        cancellables.removeAll()
    }
}

//
//  UserRepository.swift
//  HiRoute
//
//  Created by Jupond on 3/1/26.
//

import Combine
import Foundation

class UserRepository: UserProtocol {
    private let localDB = LocalDB.shared

    init() {}

    // MARK: - CRUD Operations

    func create(_ user: UserModel) -> AnyPublisher<UserModel, Error> {
        return Future<UserModel, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(UserError.unknown))
                return
            }

            self.localDB.createUser(user) { success in
                if success {
                    promise(.success(user))
                } else {
                    promise(.failure(UserError.saveFailed))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func read(uid: String) -> AnyPublisher<UserModel, Error> {
        return Future<UserModel, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(UserError.unknown))
                return
            }

            self.localDB.readUser(uid: uid) { user in
                if let user = user {
                    promise(.success(user))
                } else {
                    promise(.failure(UserError.notFound))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func update(_ user: UserModel) -> AnyPublisher<UserModel, Error> {
        return Future<UserModel, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(UserError.unknown))
                return
            }

            self.localDB.updateUser(user) { success in
                if success {
                    promise(.success(user))
                } else {
                    promise(.failure(UserError.saveFailed))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func delete(uid: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(UserError.unknown))
                return
            }

            self.localDB.deleteUser(uid: uid) { success in
                if success {
                    promise(.success(()))
                } else {
                    promise(.failure(UserError.notFound))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    deinit {
        print("UserRepository, deinit // Success : Repository 해제 완료")
    }
}

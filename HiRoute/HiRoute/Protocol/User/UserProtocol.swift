//
//  UserProtocol.swift
//  HiRoute
//
//  Created by Jupond on 3/1/26.
//

import Combine

protocol UserProtocol {
    func create(_ user: UserModel) -> AnyPublisher<UserModel, Error>
    func read(uid: String) -> AnyPublisher<UserModel, Error>
    func update(_ user: UserModel) -> AnyPublisher<UserModel, Error>
    func delete(uid: String) -> AnyPublisher<Void, Error>
}


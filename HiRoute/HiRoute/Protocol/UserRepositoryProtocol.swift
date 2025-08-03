//
//  UserRepositoryProtocol.swift
//  HiRoute
//
//  Created by Jupond on 7/26/25.
//
import Combine

protocol UserRepositoryProtocol {
    func fetchUserProfile(userUID: String) -> AnyPublisher<UserModel, Error>
    func updateUserProfile(_ user: UserModel) -> AnyPublisher<UserModel, Error>
    func fetchBookmarkedRoutes(userUID: String) -> AnyPublisher<[RouteModel], Error>
}

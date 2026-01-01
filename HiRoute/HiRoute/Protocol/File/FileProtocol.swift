//
//  FileProtocol.swift
//  HiRoute
//
//  Created by Jupond on 12/27/25.
//
import SwiftUI
import Combine

protocol FileProtocol {
    func createFile(planUID: String, data: Data, fileName: String, fileType: String) -> AnyPublisher<FileModel, Error>
    func readFile(fileUID: String) -> AnyPublisher<FileModel, Error>
    func readFiles(planUID: String) -> AnyPublisher<[FileModel], Error>
    func updateFile(fileUID: String, newFileName: String) -> AnyPublisher<FileModel, Error>
    func deleteFile(fileUID: String) -> AnyPublisher<Void, Error>
}

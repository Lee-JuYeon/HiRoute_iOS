//
//  ScheduleDeleteManager.swift
//  HiRoute
//
//  Created by Jupond on 12/5/25.
//
import Combine
import Foundation

protocol FileProtocol {
    // 1. VisitPlace 사용자 파일 (Documents + 메타데이터)
    func createFile(data: Data, fileName: String, fileType: String, visitPlaceUID: String) -> Result<FileModel, Error>
    func readFiles(visitPlaceUID: String) -> AnyPublisher<[FileModel], Error>
    func deleteFile(fileUID: String) -> AnyPublisher<Void, Error>
    
    // 2. Place API 이미지 캐싱 (Cache + URL 변환)
    func saveImage(url: String) -> AnyPublisher<String, Error> // 로컬 경로 반환
    func saveImages(place: PlaceModel) -> AnyPublisher<PlaceModel, Error> // URL → 로컬경로 변환된 Place
    func getImage(url: String) -> String? // 캐시된 이미지 로컬 경로
    
    // 공통
    func loadFileData(filePath: String) -> Result<Data, Error>
    func clearExpiredCache()
}

//
//  ScheduleReadManager.swift
//  HiRoute
//
//  Created by Jupond on 12/5/25.
//

import Foundation
import Combine
import CoreData


/**
 * FileService (싱글톤)
 * - 모든 파일 관련 작업을 하나의 서비스에서 처리
 * - VisitPlace 사용자 파일: Documents 저장 + FileEntity 메타데이터 관리
 * - Place API 이미지: Cache 저장 + URL 변환
 * - 파일 압축/해제 자동 처리
 */
class FileSingleton {
    static let shared = FileSingleton()
    
    // MARK: - Dependencies
    private let compressionManager = FileCompressionManager.shared
    
    // MARK: - CoreData Contexts
    private let mainContext = CoreDataStack.shared.context
    private let backgroundContext: NSManagedObjectContext
    
    // MARK: - File System URLs
    private lazy var documentsDirectory: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }()
    
    private lazy var cacheDirectory: URL = {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }()
    
    // MARK: - Constants
    private let maxCacheAge: TimeInterval = 7 * 24 * 60 * 60 // 7일
    private let maxCacheSize: Int64 = 500 * 1024 * 1024 // 500MB
    
    // MARK: - Reactive
    private var cancellables = Set<AnyCancellable>()
    
    /**
     * 싱글톤 초기화
     */
    private init() {
        // 백그라운드 컨텍스트 생성
        backgroundContext = CoreDataStack.shared.persistentContainer.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
        backgroundContext.undoManager = nil
        backgroundContext.shouldDeleteInaccessibleFaults = true
        
        setupDirectories()
        print("FileService, init // Success : 싱글톤 파일 서비스 초기화 완료")
    }
    
    // MARK: - VisitPlace 사용자 파일 (Documents + 메타데이터)
    
    /**
     * 사용자 파일 생성
     * - 파일 압축 후 Documents 폴더에 저장
     * - FileEntity 메타데이터도 함께 저장
     * - VisitPlace와 연결
     * @param data: 파일 바이너리 데이터
     * @param fileName: 원본 파일명
     * @param fileType: 파일 확장자
     * @param visitPlaceUID: 연결할 방문장소 UID
     * @return: 생성된 파일 모델 Result
     */
    func createFile(data: Data, fileName: String, fileType: String, planUID: String) -> Result<FileModel, Error> {
        print("FileService, createFile // Info : 사용자 파일 생성 시작 - \(fileName)")
        
        do {
            // 1. 파일 타입 검증
            try validateFileType(fileType)
            
            // 2. 파일 압축
            let compressedData = compressionManager.compressFile(data: data, fileType: fileType)
            print("FileService, createFile // Info : 압축 완료 - 원본: \(data.count)bytes, 압축: \(compressedData.count)bytes")
            
            // 3. 고유 파일명 생성
            let uniqueFileName = generateUniqueFileName(originalName: fileName, fileType: fileType)
            
            // 4. Documents 폴더에 파일 저장
            let filePath = try saveFileToDocuments(data: compressedData, fileName: uniqueFileName)
            
            // 5. FileModel 생성
            var fileModel = FileModel(
                fileName: fileName,
                fileType: fileType,
                fileSize: Int64(data.count), // 원본 크기
                filePath: filePath,
                createdDate: Date()
            )
            
            // 6. CoreData에 메타데이터 저장 (동기)
            try saveFileMetadata(fileModel, planUID: planUID)
            
            print("FileService, createFile // Success : 사용자 파일 생성 완료 - \(uniqueFileName)")
            return .success(fileModel)
            
        } catch {
            // 실패시 저장된 파일 정리
            if let filePath = try? saveFileToDocuments(data: data, fileName: generateUniqueFileName(originalName: fileName, fileType: fileType)) {
                try? FileManager.default.removeItem(atPath: filePath)
            }
            
            print("FileService, createFile // Exception : \(error.localizedDescription)")
            return .failure(error)
        }
    }
    
    /**
     * 특정 방문장소의 파일 목록 조회
     * - FileEntity에서 메타데이터 조회 후 FileModel 변환
     * @param visitPlaceUID: 방문장소 고유 식별자
     * @return: 파일 목록 Publisher
     */
    func readFiles(visitPlaceUID: String) -> AnyPublisher<[FileModel], Error> {
        print("FileService, readFiles // Info : 방문장소 파일 목록 조회 - \(visitPlaceUID)")
        
        return Future<[FileModel], Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(FileError.operationFailed))
                return
            }
            
            self.backgroundContext.perform {
                do {
                    let request: NSFetchRequest<FileEntity> = FileEntity.fetchRequest()
                    request.predicate = NSPredicate(format: "visitPlace.uid == %@", visitPlaceUID)
                    request.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: false)]
                    request.fetchBatchSize = 20
                    
                    let entities = try self.backgroundContext.fetch(request)
                    let fileModels = entities.compactMap { self.convertToModel($0) }
                    
                    print("FileService, readFiles // Success : 파일 목록 조회 완료 - \(fileModels.count)개")
                    promise(.success(fileModels))
                    
                } catch {
                    print("FileService, readFiles // Exception : \(error.localizedDescription)")
                    promise(.failure(FileError.operationFailed))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    /**
     * 사용자 파일 삭제
     * - FileEntity에서 파일 경로 조회 후 실제 파일 삭제
     * - 메타데이터도 함께 삭제
     * @param fileUID: 삭제할 파일의 고유 식별자
     * @return: 삭제 완료 Publisher
     */
    func deleteFile(fileUID: String) -> AnyPublisher<Void, Error> {
        print("FileService, deleteFile // Info : 사용자 파일 삭제 시작 - \(fileUID)")
        
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(FileError.operationFailed))
                return
            }
            
            self.backgroundContext.perform {
                do {
                    // FileEntity 조회
                    let request: NSFetchRequest<FileEntity> = FileEntity.fetchRequest()
                    request.predicate = NSPredicate(format: "id == %@", fileUID)
                    request.fetchLimit = 1
                    
                    guard let entity = try self.backgroundContext.fetch(request).first,
                          let filePath = entity.filePath else {
                        promise(.failure(FileError.fileNotFound))
                        return
                    }
                    
                    // 1. 실제 파일 삭제
                    try FileManager.default.removeItem(atPath: filePath)
                    
                    // 2. 메타데이터 삭제
                    self.backgroundContext.delete(entity)
                    try self.backgroundContext.save()
                    
                    print("FileService, deleteFile // Success : 사용자 파일 삭제 완료 - \(fileUID)")
                    promise(.success(()))
                    
                } catch {
                    self.backgroundContext.rollback()
                    print("FileService, deleteFile // Exception : \(error.localizedDescription)")
                    promise(.failure(FileError.deleteFailed))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Place API 이미지 캐싱 (Cache + URL 변환)
    
    /**
     * API 이미지 다운로드 및 캐싱
     * - 네트워크에서 이미지 다운로드
     * - Cache 폴더에 압축하여 저장
     * @param url: 다운로드할 이미지 URL
     * @return: 저장된 로컬 파일 경로 Publisher
     */
    func saveImage(url: String) -> AnyPublisher<String, Error> {
        print("FileService, saveImage // Info : API 이미지 다운로드 시작 - \(url)")
        
        // 1. 이미 캐시된 이미지 확인
        if let cachedPath = getImage(url: url) {
            print("FileService, saveImage // Success : 캐시된 이미지 사용 - \(url)")
            return Just(cachedPath)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        // 2. 네트워크에서 다운로드
        guard let imageURL = URL(string: url) else {
            return Fail(error: FileError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: imageURL)
            .map(\.data)
            .tryMap { [weak self] data in
                guard let self = self else { throw FileError.operationFailed }
                
                // 3. 이미지 압축
                let compressedData = self.compressionManager.compressImage(data: data, quality: 0.8)
                
                // 4. 캐시 파일명 생성 및 저장
                let cacheFileName = self.generateCacheFileName(from: url)
                return try self.saveFileToCache(data: compressedData, fileName: cacheFileName)
            }
            .handleEvents(
                receiveOutput: { localPath in
                    print("FileService, saveImage // Success : API 이미지 캐싱 완료 - \(url)")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("FileService, saveImage // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    /**
     * Place 모델의 모든 이미지 캐싱
     * - 썸네일 이미지 + 리뷰 이미지들을 일괄 다운로드
     * - URL들을 로컬 경로로 변환한 새 PlaceModel 반환
     * @param place: 이미지 URL들이 포함된 Place 모델
     * @return: 로컬 경로로 변환된 Place 모델 Publisher
     */
    func saveImages(place: PlaceModel) -> AnyPublisher<PlaceModel, Error> {
        print("FileService, saveImages // Info : Place 이미지 일괄 캐싱 시작 - \(place.title)")
        
        var imagePublishers: [AnyPublisher<(String, String), Error>] = []
        
        // 1. 썸네일 이미지
        if let thumbnailURL = place.thumbnailImageURL, !thumbnailURL.isEmpty {
            let publisher = saveImage(url: thumbnailURL)
                .map { localPath in (thumbnailURL, localPath) }
                .eraseToAnyPublisher()
            imagePublishers.append(publisher)
        }
        
        // 2. 리뷰 이미지들
        for review in place.reviews {
            for reviewImage in review.images {
                let publisher = saveImage(url: reviewImage.imageURL)
                    .map { localPath in (reviewImage.imageURL, localPath) }
                    .eraseToAnyPublisher()
                imagePublishers.append(publisher)
            }
        }
        
        // 3. 모든 이미지 병렬 다운로드
        return Publishers.MergeMany(imagePublishers)
            .collect()
            .map { urlPathPairs in
                let urlToPathMap = Dictionary(urlPathPairs, uniquingKeysWith: { first, _ in first })
                return self.convertPlaceURLsToLocalPaths(place: place, urlToPathMap: urlToPathMap)
            }
            .handleEvents(
                receiveOutput: { _ in
                    print("FileService, saveImages // Success : Place 이미지 일괄 캐싱 완료 - \(place.title)")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("FileService, saveImages // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    /**
     * 캐시된 이미지 경로 조회
     * - URL에 해당하는 캐시 파일 존재 여부 및 만료 확인
     * @param url: 확인할 이미지 URL
     * @return: 캐시된 로컬 파일 경로 (없거나 만료된 경우 nil)
     */
    func getImage(url: String) -> String? {
        let cacheFileName = generateCacheFileName(from: url)
        let cachePath = cacheDirectory.appendingPathComponent("images").appendingPathComponent(cacheFileName).path
        
        if FileManager.default.fileExists(atPath: cachePath) {
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: cachePath)
                if let creationDate = attributes[.creationDate] as? Date {
                    let age = Date().timeIntervalSince(creationDate)
                    if age < maxCacheAge {
                        return cachePath
                    } else {
                        // 만료된 파일 삭제
                        try? FileManager.default.removeItem(atPath: cachePath)
                        print("FileService, getImage // Info : 만료된 캐시 파일 삭제 - \(cacheFileName)")
                        return nil
                    }
                }
            } catch {
                print("FileService, getImage // Warning : 캐시 파일 확인 실패 - \(error.localizedDescription)")
            }
        }
        
        return nil
    }
    
    // MARK: - 공통 메서드
    
    /**
     * 파일 데이터 로드 (압축 해제)
     * - 로컬 경로에서 파일 데이터를 메모리로 로드
     * - 필요시 압축 해제하여 원본 데이터 반환
     * @param filePath: 로드할 파일의 로컬 경로
     * @return: 파일 바이너리 데이터 Result
     */
    func loadFileData(filePath: String) -> Result<Data, Error> {
        do {
            let compressedData = try Data(contentsOf: URL(fileURLWithPath: filePath))
            
            // 파일 확장자 확인하여 압축 해제
            let fileExtension = URL(fileURLWithPath: filePath).pathExtension
            let decompressedData = compressionManager.decompressFile(data: compressedData, fileType: fileExtension)
            
            print("FileService, loadFileData // Success : 파일 로드 및 압축해제 완료 - \(filePath)")
            return .success(decompressedData)
        } catch {
            print("FileService, loadFileData // Exception : \(error.localizedDescription)")
            return .failure(FileError.loadFailed)
        }
    }
    
    /**
     * 만료된 캐시 정리
     * - 7일 이상 된 캐시 파일들 삭제
     * - 캐시 크기가 500MB 초과시 오래된 순으로 삭제
     */
    func clearExpiredCache() {
        print("FileService, clearExpiredCache // Info : 만료된 캐시 정리 시작")
        
        let imagesDirectory = cacheDirectory.appendingPathComponent("images")
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: imagesDirectory,
                includingPropertiesForKeys: [.creationDateKey, .fileSizeKey],
                options: .skipsHiddenFiles
            )
            
            var totalSize: Int64 = 0
            var fileInfos: [(url: URL, creationDate: Date, size: Int64)] = []
            
            // 파일 정보 수집
            for fileURL in fileURLs {
                let attributes = try fileURL.resourceValues(forKeys: [.creationDateKey, .fileSizeKey])
                if let creationDate = attributes.creationDate,
                   let fileSize = attributes.fileSize {
                    totalSize += Int64(fileSize)
                    fileInfos.append((url: fileURL, creationDate: creationDate, size: Int64(fileSize)))
                }
            }
            
            var deletedCount = 0
            
            // 만료된 파일 삭제 (7일 이상)
            let expiredFiles = fileInfos.filter { Date().timeIntervalSince($0.creationDate) > maxCacheAge }
            for fileInfo in expiredFiles {
                try FileManager.default.removeItem(at: fileInfo.url)
                totalSize -= fileInfo.size
                deletedCount += 1
            }
            
            // 크기 초과시 오래된 파일부터 삭제
            if totalSize > maxCacheSize {
                let remainingFiles = fileInfos.filter { Date().timeIntervalSince($0.creationDate) <= maxCacheAge }
                let sortedFiles = remainingFiles.sorted { $0.creationDate < $1.creationDate }
                
                for fileInfo in sortedFiles {
                    if totalSize <= maxCacheSize { break }
                    
                    try FileManager.default.removeItem(at: fileInfo.url)
                    totalSize -= fileInfo.size
                    deletedCount += 1
                }
            }
            
            print("FileService, clearExpiredCache // Success : 캐시 정리 완료 - 삭제: \(deletedCount)개, 총 크기: \(totalSize / 1024 / 1024)MB")
            
        } catch {
            print("FileService, clearExpiredCache // Exception : \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Helper Methods
    
    /**
     * 디렉터리 설정
     */
    private func setupDirectories() {
        let directories = [
            documentsDirectory.appendingPathComponent("files"),
            cacheDirectory.appendingPathComponent("images")
        ]
        
        for directory in directories {
            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            } catch {
                print("FileService, setupDirectories // Warning : 디렉터리 생성 실패 - \(error.localizedDescription)")
            }
        }
    }
    
    /**
     * FileEntity 메타데이터 저장 (동기)
     */
    private func saveFileMetadata(_ fileModel: FileModel, planUID: String) throws {
        var saveError: Error?
        
        backgroundContext.performAndWait {
            do {
                // VisitPlace 조회
                let planRequest: NSFetchRequest<PlanEntity> = PlanEntity.fetchRequest()
                planRequest.predicate = NSPredicate(format: "uid == %@", planUID)
                planRequest.fetchLimit = 1
                
                guard let planEntity = try backgroundContext.fetch(planRequest).first else {
                    saveError = FileError.operationFailed
                    return
                }
                
                // FileEntity 생성
                let fileEntity = FileEntity(context: backgroundContext)
                fileEntity.id = fileModel.id.uuidString
                fileEntity.fileName = fileModel.fileName
                fileEntity.fileType = fileModel.fileType
                fileEntity.fileSize = fileModel.fileSize
                fileEntity.filePath = fileModel.filePath
                fileEntity.createdDate = fileModel.createdDate
                fileEntity.visitPlace = planEntity
                
                try backgroundContext.save()
                
            } catch {
                backgroundContext.rollback()
                saveError = error
            }
        }
        
        if let error = saveError {
            throw error
        }
    }
    
    /**
     * 파일 타입 검증
     */
    private func validateFileType(_ fileType: String) throws {
        let supportedTypes = ["jpg", "jpeg", "png", "gif", "pdf", "txt", "doc", "docx"]
        if !supportedTypes.contains(fileType.lowercased()) {
            throw FileError.unsupportedFileType
        }
    }
    
    /**
     * 고유 파일명 생성
     */
    private func generateUniqueFileName(originalName: String, fileType: String) -> String {
        let uuid = UUID().uuidString.prefix(8)
        let baseName = originalName.replacingOccurrences(of: " ", with: "_")
        return "\(uuid)_\(baseName).\(fileType)"
    }
    
    /**
     * 캐시 파일명 생성
     */
    private func generateCacheFileName(from url: String) -> String {
        let hash = abs(url.hashValue)
        let fileExtension = URL(string: url)?.pathExtension ?? "jpg"
        return "\(hash).\(fileExtension)"
    }
    
    /**
     * Documents 폴더에 파일 저장
     */
    private func saveFileToDocuments(data: Data, fileName: String) throws -> String {
        let fileURL = documentsDirectory.appendingPathComponent("files").appendingPathComponent(fileName)
        try data.write(to: fileURL)
        return fileURL.path
    }
    
    /**
     * Cache 폴더에 파일 저장
     */
    private func saveFileToCache(data: Data, fileName: String) throws -> String {
        let fileURL = cacheDirectory.appendingPathComponent("images").appendingPathComponent(fileName)
        try data.write(to: fileURL)
        return fileURL.path
    }
    
    /**
     * FileEntity → FileModel 변환
     */
    private func convertToModel(_ entity: FileEntity) -> FileModel? {
        guard let idString = entity.id,
              let uuid = UUID(uuidString: idString),
              let fileName = entity.fileName,
              let fileType = entity.fileType,
              let filePath = entity.filePath,
              let createdDate = entity.createdDate else { return nil }
        
        var fileModel = FileModel(
            fileName: fileName,
            fileType: fileType,
            fileSize: entity.fileSize,
            filePath: filePath,
            createdDate: createdDate
        )
        fileModel.id = uuid
        
        return fileModel
    }
    
    /**
     * PlaceModel의 URL들을 로컬 경로로 변환
     */
    private func convertPlaceURLsToLocalPaths(place: PlaceModel, urlToPathMap: [String: String]) -> PlaceModel {
        // 썸네일 이미지 URL 변환
        let localThumbnailURL = place.thumbnailImageURL.flatMap { urlToPathMap[$0] } ?? place.thumbnailImageURL
        
        // 리뷰 이미지 URL들 변환
        let updatedReviews = place.reviews.map { review in
            let updatedImages = review.images.map { reviewImage in
                let localImageURL = urlToPathMap[reviewImage.imageURL] ?? reviewImage.imageURL
                return ReviewImageModel(
                    uid: reviewImage.uid,           // 기존 uid 유지
                    userUID: reviewImage.userUID,   // 기존 userUID 유지
                    date: reviewImage.date,         // 기존 date 유지
                    imageURL: localImageURL         // URL만 로컬 경로로 변경
                )
            }
            
            return ReviewModel(
                reviewUID: review.reviewUID,        // 리뷰 고유 UID
                reviewText: review.reviewText,      // 리뷰 내용
                userUID: review.userUID,            // 작성자 UID
                userName: review.userName,          // 작성자 이름
                visitDate: review.visitDate,        // 방문 날짜
                usefulCount: review.usefulCount,    // 도움돼요 수
                images: updatedImages,              // 업데이트된 이미지들
                usefulList: review.usefulList       // 유용함 목록
            )
        }
        
        return PlaceModel(
            uid: place.uid,
            address: place.address,                 // 주소 모델
            type: place.type,                       // 장소 타입
            title: place.title,
            subtitle: place.subtitle,
            thumbnailImageURL: localThumbnailURL,   // 변환된 썸네일 URL
            workingTimes: place.workingTimes,       // 운영시간 배열
            reviews: updatedReviews,                // URL 변환된 리뷰들
            bookMarks: place.bookMarks,             // 북마크 목록
            stars: place.stars                      // 별점 목록
        )
    }
    
    deinit {
        cancellables.removeAll()
        print("FileService, deinit // Success : 싱글톤 파일 서비스 해제 (실제로는 발생하지 않음)")
    }
}

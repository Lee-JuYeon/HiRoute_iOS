//
//  ScheduleCreateManager.swift
//  HiRoute
//
//  Created by Jupond on 12/5/25.
//
import Combine
import Foundation

class PlanRepository: PlanProtocol, FileProtocol {
    private let localDB = LocalDB.shared
    private let compressionManager = FileCompressionManager.shared
    private let fileManager = FileManager.default
    private let documentsDirectory: URL
    
    init() {
        documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        setupFileDirectories()
        print("PlanRepository, init // Success : Repository 초기화 완료")
    }
    
    // MARK: - Plan CRUD Operations (비동기)
    
    func createPlan(_ planModel: PlanModel, scheduleUID: String) -> AnyPublisher<PlanModel, Error> {
        return Future<PlanModel, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(PlanError.unknown))
                return
            }
            
            // 중복 체크 (비동기)
            self.localDB.readPlan(planUID: planModel.uid) { existingPlan in
                if existingPlan != nil {
                    promise(.failure(PlanError.duplicatePlan))
                    print("PlanRepository, createPlan // Warning : 중복된 Plan - \(planModel.uid)")
                    return
                }
                
                // Plan 생성 (비동기)
                self.localDB.createPlan(planModel, scheduleUID: scheduleUID) { success in
                    if success {
                        promise(.success(planModel))
                        print("PlanRepository, createPlan // Success : Plan 생성 완료 - \(planModel.uid)")
                    } else {
                        promise(.failure(PlanError.saveFailed))
                        print("PlanRepository, createPlan // Exception : Plan 생성 실패")
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func readPlan(planUID: String) -> AnyPublisher<PlanModel, Error> {
        return Future<PlanModel, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(PlanError.unknown))
                return
            }
            
            self.localDB.readPlan(planUID: planUID) { plan in
                if let plan = plan {
                    promise(.success(plan))
                    print("PlanRepository, readPlan // Success : Plan 조회 완료 - \(planUID)")
                } else {
                    promise(.failure(PlanError.planNotFound))
                    print("PlanRepository, readPlan // Warning : Plan을 찾을 수 없음 - \(planUID)")
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func readPlanList(scheduleUID: String) -> AnyPublisher<[PlanModel], Error> {
        return Future<[PlanModel], Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(PlanError.unknown))
                return
            }
            
            self.localDB.readPlanList(scheduleUID: scheduleUID) { plans in
                promise(.success(plans))
                print("PlanRepository, readPlanList // Success : Plan 목록 조회 완료 - \(plans.count)개")
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updatePlan(_ planModel: PlanModel) -> AnyPublisher<PlanModel, Error> {
        return Future<PlanModel, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(PlanError.unknown))
                return
            }
            
            // 존재 여부 확인 (비동기)
            self.localDB.readPlan(planUID: planModel.uid) { existingPlan in
                guard let existingPlan = existingPlan else {
                    promise(.failure(PlanError.planNotFound))
                    print("PlanRepository, updatePlan // Warning : 업데이트할 Plan을 찾을 수 없음 - \(planModel.uid)")
                    return
                }
                
                // 삭제된 파일들 정리
                self.cleanupRemovedFiles(existingPlan: existingPlan, newPlan: planModel)
                
                // Plan 업데이트 (비동기)
                self.localDB.updatePlan(planModel) { success in
                    if success {
                        promise(.success(planModel))
                        print("PlanRepository, updatePlan // Success : Plan 업데이트 완료 - \(planModel.uid)")
                    } else {
                        promise(.failure(PlanError.updateFailed))
                        print("PlanRepository, updatePlan // Exception : Plan 업데이트 실패")
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deletePlan(planUID: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(PlanError.unknown))
                return
            }
            
            // 존재 여부 확인 및 파일 정리 (비동기)
            self.localDB.readPlan(planUID: planUID) { existingPlan in
                guard let existingPlan = existingPlan else {
                    promise(.failure(PlanError.planNotFound))
                    print("PlanRepository, deletePlan // Warning : 삭제할 Plan을 찾을 수 없음 - \(planUID)")
                    return
                }
                
                // 연결된 모든 파일 삭제
                self.deleteAllPlanFiles(existingPlan)
                
                // Plan 삭제 (비동기)
                self.localDB.deletePlan(planUID: planUID) { success in
                    if success {
                        promise(.success(()))
                        print("PlanRepository, deletePlan // Success : Plan 삭제 완료 - \(planUID)")
                    } else {
                        promise(.failure(PlanError.deleteFailed))
                        print("PlanRepository, deletePlan // Exception : Plan 삭제 실패")
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updatePlanMemo(planUID: String, memo: String) -> AnyPublisher<PlanModel, Error> {
        return Future<PlanModel, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(PlanError.unknown))
                return
            }
            
            // 존재 여부 확인 (비동기)
            self.localDB.readPlan(planUID: planUID) { existingPlan in
                guard existingPlan != nil else {
                    promise(.failure(PlanError.planNotFound))
                    print("PlanRepository, updatePlanMemo // Warning : Plan을 찾을 수 없음 - \(planUID)")
                    return
                }
                
                // 메모 업데이트 (비동기)
                self.localDB.updatePlanMemo(planUID: planUID, memo: memo) { success in
                    if success {
                        // 업데이트된 Plan 재조회 (비동기)
                        self.localDB.readPlan(planUID: planUID) { updatedPlan in
                            if let updatedPlan = updatedPlan {
                                promise(.success(updatedPlan))
                                print("PlanRepository, updatePlanMemo // Success : Plan 메모 업데이트 완료 - \(planUID)")
                            } else {
                                promise(.failure(PlanError.updateFailed))
                            }
                        }
                    } else {
                        promise(.failure(PlanError.updateFailed))
                        print("PlanRepository, updatePlanMemo // Exception : Plan 메모 업데이트 실패")
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updatePlanIndex(planUID: String, newIndex: Int) -> AnyPublisher<PlanModel, Error> {
        return Future<PlanModel, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(PlanError.unknown))
                return
            }
            
            // 존재 여부 확인 (비동기)
            self.localDB.readPlan(planUID: planUID) { existingPlan in
                guard existingPlan != nil else {
                    promise(.failure(PlanError.planNotFound))
                    print("PlanRepository, updatePlanIndex // Warning : Plan을 찾을 수 없음 - \(planUID)")
                    return
                }
                
                // 인덱스 업데이트 (비동기)
                self.localDB.updatePlanIndex(planUID: planUID, newIndex: newIndex) { success in
                    if success {
                        // 업데이트된 Plan 재조회 (비동기)
                        self.localDB.readPlan(planUID: planUID) { updatedPlan in
                            if let updatedPlan = updatedPlan {
                                promise(.success(updatedPlan))
                                print("PlanRepository, updatePlanIndex // Success : Plan 인덱스 업데이트 완료 - \(planUID) → \(newIndex)")
                            } else {
                                promise(.failure(PlanError.updateFailed))
                            }
                        }
                    } else {
                        promise(.failure(PlanError.updateFailed))
                        print("PlanRepository, updatePlanIndex // Exception : Plan 인덱스 업데이트 실패")
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func reorderPlans(planUIDs: [String]) -> AnyPublisher<[PlanModel], Error> {
        return Future<[PlanModel], Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(PlanError.unknown))
                return
            }
            
            // 모든 Plan 존재 확인 (순차적 비동기 체크)
            self.validateAllPlansExist(planUIDs: planUIDs) { allExist in
                guard allExist else {
                    promise(.failure(PlanError.planNotFound))
                    print("PlanRepository, reorderPlans // Warning : 일부 Plan을 찾을 수 없음")
                    return
                }
                
                // 순서 업데이트 (순차적 비동기 처리)
                self.updatePlanIndices(planUIDs: planUIDs) { updatedPlans in
                    if let updatedPlans = updatedPlans {
                        promise(.success(updatedPlans))
                        print("PlanRepository, reorderPlans // Success : Plan 순서 변경 완료 - \(planUIDs.count)개")
                    } else {
                        promise(.failure(PlanError.reorderFailed))
                        print("PlanRepository, reorderPlans // Exception : Plan 순서 변경 실패")
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - File CRUD Operations (비동기)
    
    func createFile(planUID: String, data: Data, fileName: String, fileType: String) -> AnyPublisher<FileModel, Error> {
        return Future<FileModel, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(FileError.operationFailed))
                return
            }
            
            print("PlanRepository, createFile // Info : 파일 생성 시작 - \(fileName)")
            
            // Plan 존재 확인 (비동기)
            self.localDB.readPlan(planUID: planUID) { existingPlan in
                guard var existingPlan = existingPlan else {
                    promise(.failure(FileError.fileNotFound))
                    print("PlanRepository, createFile // Warning : Plan을 찾을 수 없음 - \(planUID)")
                    return
                }
                
                do {
                    // 파일 압축 및 저장
                    let compressedData = self.compressionManager.compressFile(data: data, fileType: fileType)
                    let uniqueFileName = self.generateUniqueFileName(originalName: fileName, fileType: fileType, planUID: planUID)
                    let filePath = try self.saveFileToDocuments(data: compressedData, fileName: uniqueFileName)
                    
                    // FileModel 생성
                    let fileModel = FileModel(
                        fileName: fileName,
                        fileType: fileType,
                        fileSize: Int64(data.count),
                        filePath: filePath,
                        createdDate: Date()
                    )
                    
                    // Plan 업데이트 (비동기)
                    let updatedFiles = existingPlan.files + [fileModel]
                    let updatedPlan = PlanModel(
                        uid: existingPlan.uid,
                        index: existingPlan.index,
                        memo: existingPlan.memo,
                        placeModel: existingPlan.placeModel,
                        files: updatedFiles
                    )
                    
                    self.localDB.updatePlan(updatedPlan) { success in
                        if success {
                            promise(.success(fileModel))
                            print("PlanRepository, createFile // Success : 파일 생성 완료 - \(fileName)")
                        } else {
                            // 롤백: 파일 시스템에서 삭제
                            try? self.fileManager.removeItem(atPath: filePath)
                            promise(.failure(FileError.saveFailed))
                            print("PlanRepository, createFile // Exception : Plan 업데이트 실패")
                        }
                    }
                } catch {
                    promise(.failure(FileError.operationFailed))
                    print("PlanRepository, createFile // Exception : 파일 저장 실패 - \(error.localizedDescription)")
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func readFile(fileUID: String) -> AnyPublisher<FileModel, Error> {
        return Future<FileModel, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(FileError.operationFailed))
                return
            }
            
            // 모든 Plan에서 파일 검색 (비동기)
            self.searchFileInAllPlans(fileUID: fileUID) { foundFile in
                if let file = foundFile {
                    promise(.success(file))
                    print("PlanRepository, readFile // Success : 파일 조회 완료 - \(fileUID)")
                } else {
                    promise(.failure(FileError.fileNotFound))
                    print("PlanRepository, readFile // Warning : 파일을 찾을 수 없음 - \(fileUID)")
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func readFiles(planUID: String) -> AnyPublisher<[FileModel], Error> {
        return Future<[FileModel], Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(FileError.operationFailed))
                return
            }
            
            self.localDB.readPlan(planUID: planUID) { plan in
                if let plan = plan {
                    promise(.success(plan.files))
                    print("PlanRepository, readFiles // Success : 파일 목록 조회 완료 - \(plan.files.count)개")
                } else {
                    promise(.failure(FileError.fileNotFound))
                    print("PlanRepository, readFiles // Warning : Plan을 찾을 수 없음 - \(planUID)")
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateFile(fileUID: String, newFileName: String) -> AnyPublisher<FileModel, Error> {
        return Future<FileModel, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(FileError.operationFailed))
                return
            }
            
            // 파일이 속한 Plan 찾기 (비동기)
            self.findPlanContainingFile(fileUID: fileUID) { result in
                if let (plan, fileIndex) = result {
                    let oldFile = plan.files[fileIndex]
                    
                    // FileModel 업데이트
                    let updatedFile = FileModel(
                        fileName: newFileName,
                        fileType: oldFile.fileType,
                        fileSize: oldFile.fileSize,
                        filePath: oldFile.filePath,
                        createdDate: oldFile.createdDate
                    )
                    
                    // Plan 업데이트 (비동기)
                    var updatedFiles = plan.files
                    updatedFiles[fileIndex] = updatedFile
                    
                    let updatedPlan = PlanModel(
                        uid: plan.uid,
                        index: plan.index,
                        memo: plan.memo,
                        placeModel: plan.placeModel,
                        files: updatedFiles
                    )
                    
                    self.localDB.updatePlan(updatedPlan) { success in
                        if success {
                            promise(.success(updatedFile))
                            print("PlanRepository, updateFile // Success : 파일명 업데이트 완료 - \(newFileName)")
                        } else {
                            promise(.failure(FileError.operationFailed))
                            print("PlanRepository, updateFile // Exception : Plan 업데이트 실패")
                        }
                    }
                } else {
                    promise(.failure(FileError.fileNotFound))
                    print("PlanRepository, updateFile // Warning : 파일을 찾을 수 없음 - \(fileUID)")
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteFile(fileUID: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(FileError.operationFailed))
                return
            }
            
            // 파일이 속한 Plan 찾기 (비동기)
            self.findPlanContainingFile(fileUID: fileUID) { result in
                if let (plan, fileIndex) = result {
                    let fileToDelete = plan.files[fileIndex]
                    
                    // 파일 시스템에서 삭제
                    self.deleteFileFromSystem(filePath: fileToDelete.filePath)
                    
                    // Plan 업데이트 (비동기)
                    var updatedFiles = plan.files
                    updatedFiles.remove(at: fileIndex)
                    
                    let updatedPlan = PlanModel(
                        uid: plan.uid,
                        index: plan.index,
                        memo: plan.memo,
                        placeModel: plan.placeModel,
                        files: updatedFiles
                    )
                    
                    self.localDB.updatePlan(updatedPlan) { success in
                        if success {
                            promise(.success(()))
                            print("PlanRepository, deleteFile // Success : 파일 삭제 완료 - \(fileUID)")
                        } else {
                            promise(.failure(FileError.deleteFailed))
                            print("PlanRepository, deleteFile // Exception : Plan 업데이트 실패")
                        }
                    }
                } else {
                    promise(.failure(FileError.fileNotFound))
                    print("PlanRepository, deleteFile // Warning : 파일을 찾을 수 없음 - \(fileUID)")
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Methods (비동기)
    
    private func validateAllPlansExist(planUIDs: [String], completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        var allExist = true
        
        for planUID in planUIDs {
            group.enter()
            localDB.readPlan(planUID: planUID) { plan in
                if plan == nil {
                    allExist = false
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(allExist)
        }
    }
    
    private func updatePlanIndices(planUIDs: [String], completion: @escaping ([PlanModel]?) -> Void) {
        var updatedPlans: [PlanModel] = []
        let group = DispatchGroup()
        var hasError = false
        
        for (newIndex, planUID) in planUIDs.enumerated() {
            group.enter()
            localDB.updatePlanIndex(planUID: planUID, newIndex: newIndex) { success in
                if success {
                    self.localDB.readPlan(planUID: planUID) { plan in
                        if let plan = plan {
                            updatedPlans.append(plan)
                        } else {
                            hasError = true
                        }
                        group.leave()
                    }
                } else {
                    hasError = true
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            completion(hasError ? nil : updatedPlans.sorted { $0.index < $1.index })
        }
    }
    
    private func searchFileInAllPlans(fileUID: String, completion: @escaping (FileModel?) -> Void) {
        // TODO: LocalDB에 모든 Plan 조회 메서드 필요
        // 임시로 nil 반환
        completion(nil)
    }
    
    private func findPlanContainingFile(fileUID: String, completion: @escaping ((PlanModel, Int)?) -> Void) {
        // TODO: LocalDB에 모든 Plan 조회 메서드 필요
        // 임시로 nil 반환
        completion(nil)
    }
    
    // MARK: - Helper Methods (동기)
    
    private func setupFileDirectories() {
        let filesDirectory = documentsDirectory.appendingPathComponent("files")
        
        do {
            try fileManager.createDirectory(at: filesDirectory, withIntermediateDirectories: true)
            print("PlanRepository, setupFileDirectories // Success : files 디렉토리 생성")
        } catch {
            print("PlanRepository, setupFileDirectories // Warning : 디렉토리 생성 실패 - \(error.localizedDescription)")
        }
    }
    
    private func generateUniqueFileName(originalName: String, fileType: String, planUID: String) -> String {
        let uuid = UUID().uuidString.prefix(8)
        let sanitizedName = originalName.replacingOccurrences(of: " ", with: "_")
        return "\(planUID)_\(uuid)_\(sanitizedName).\(fileType)"
    }
    
    private func saveFileToDocuments(data: Data, fileName: String) throws -> String {
        let fileURL = documentsDirectory.appendingPathComponent("files").appendingPathComponent(fileName)
        try data.write(to: fileURL)
        return fileURL.path
    }
    
    private func deleteFileFromSystem(filePath: String) {
        do {
            if fileManager.fileExists(atPath: filePath) {
                try fileManager.removeItem(atPath: filePath)
                print("PlanRepository, deleteFileFromSystem // Success : 파일 시스템 삭제 완료 - \(filePath)")
            }
        } catch {
            print("PlanRepository, deleteFileFromSystem // Warning : 파일 시스템 삭제 실패 - \(error.localizedDescription)")
        }
    }
    
    private func cleanupRemovedFiles(existingPlan: PlanModel, newPlan: PlanModel) {
        let newFileIDs = Set(newPlan.files.map { $0.id.uuidString })
        let removedFiles = existingPlan.files.filter { !newFileIDs.contains($0.id.uuidString) }
        
        for file in removedFiles {
            deleteFileFromSystem(filePath: file.filePath)
            print("PlanRepository, cleanupRemovedFiles // Info : 제거된 파일 삭제 - \(file.fileName)")
        }
    }
    
    private func deleteAllPlanFiles(_ plan: PlanModel) {
        for file in plan.files {
            deleteFileFromSystem(filePath: file.filePath)
            print("PlanRepository, deleteAllPlanFiles // Info : 파일 삭제 - \(file.fileName)")
        }
    }
    
    deinit {
        print("PlanRepository, deinit // Success : Repository 해제 완료")
    }
}


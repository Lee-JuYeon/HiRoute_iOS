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
        // Documents/files 디렉토리 설정
        documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        setupFileDirectories()
        print("PlanRepository, init // Success : Repository 초기화 완료")
    }
    
    // MARK: - Plan CRUD Operations (기존과 동일)
    
    func createPlan(_ planModel: PlanModel) -> AnyPublisher<PlanModel, Error> {
        return Future<PlanModel, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(PlanError.unknown))
                return
            }
            
            // ✅ 중복 체크
            if let _ = self.localDB.readPlan(planUID: planModel.uid) {
                promise(.failure(PlanError.duplicatePlan))
                print("PlanRepository, createPlan // Warning : 중복된 Plan - \(planModel.uid)")
                return
            }
            
            // TODO: scheduleUID를 매개변수로 받도록 프로토콜 수정 필요
            let scheduleUID = "temp_schedule_uid"
            let success = self.localDB.createPlan(planModel, scheduleUID: scheduleUID)
            
            if success {
                promise(.success(planModel))
                print("PlanRepository, createPlan // Success : Plan 생성 완료 - \(planModel.uid)")
            } else {
                promise(.failure(PlanError.saveFailed))
                print("PlanRepository, createPlan // Exception : Plan 생성 실패")
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
            
            if let plan = self.localDB.readPlan(planUID: planUID) {
                promise(.success(plan))
                print("PlanRepository, readPlan // Success : Plan 조회 완료 - \(planUID)")
            } else {
                promise(.failure(PlanError.planNotFound))
                print("PlanRepository, readPlan // Warning : Plan을 찾을 수 없음 - \(planUID)")
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
            
            let plans = self.localDB.readPlanList(scheduleUID: scheduleUID)
            promise(.success(plans))
            print("PlanRepository, readPlanList // Success : Plan 목록 조회 완료 - \(plans.count)개")
        }
        .eraseToAnyPublisher()
    }
    
    func updatePlan(_ planModel: PlanModel) -> AnyPublisher<PlanModel, Error> {
        return Future<PlanModel, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(PlanError.unknown))
                return
            }
            
            // ✅ 존재 여부 확인
            guard let existingPlan = self.localDB.readPlan(planUID: planModel.uid) else {
                promise(.failure(PlanError.planNotFound))
                print("PlanRepository, updatePlan // Warning : 업데이트할 Plan을 찾을 수 없음 - \(planModel.uid)")
                return
            }
            
            // ✅ 삭제된 파일들 정리 (기존 파일 중 새 모델에 없는 것들)
            self.cleanupRemovedFiles(existingPlan: existingPlan, newPlan: planModel)
            
            let success = self.localDB.updatePlan(planModel)
            
            if success {
                promise(.success(planModel))
                print("PlanRepository, updatePlan // Success : Plan 업데이트 완료 - \(planModel.uid)")
            } else {
                promise(.failure(PlanError.updateFailed))
                print("PlanRepository, updatePlan // Exception : Plan 업데이트 실패")
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
            
            // ✅ 존재 여부 확인 및 파일 정리
            guard let existingPlan = self.localDB.readPlan(planUID: planUID) else {
                promise(.failure(PlanError.planNotFound))
                print("PlanRepository, deletePlan // Warning : 삭제할 Plan을 찾을 수 없음 - \(planUID)")
                return
            }
            
            // ✅ 연결된 모든 파일 삭제
            self.deleteAllPlanFiles(existingPlan)
            
            let success = self.localDB.deletePlan(planUID: planUID)
            
            if success {
                promise(.success(()))
                print("PlanRepository, deletePlan // Success : Plan 삭제 완료 - \(planUID)")
            } else {
                promise(.failure(PlanError.deleteFailed))
                print("PlanRepository, deletePlan // Exception : Plan 삭제 실패")
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
            
            guard let _ = self.localDB.readPlan(planUID: planUID) else {
                promise(.failure(PlanError.planNotFound))
                print("PlanRepository, updatePlanMemo // Warning : Plan을 찾을 수 없음 - \(planUID)")
                return
            }
            
            let success = self.localDB.updatePlanMemo(planUID: planUID, memo: memo)
            
            if success, let updatedPlan = self.localDB.readPlan(planUID: planUID) {
                promise(.success(updatedPlan))
                print("PlanRepository, updatePlanMemo // Success : Plan 메모 업데이트 완료 - \(planUID)")
            } else {
                promise(.failure(PlanError.updateFailed))
                print("PlanRepository, updatePlanMemo // Exception : Plan 메모 업데이트 실패")
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
            
            guard let _ = self.localDB.readPlan(planUID: planUID) else {
                promise(.failure(PlanError.planNotFound))
                print("PlanRepository, updatePlanIndex // Warning : Plan을 찾을 수 없음 - \(planUID)")
                return
            }
            
            let success = self.localDB.updatePlanIndex(planUID: planUID, newIndex: newIndex)
            
            if success, let updatedPlan = self.localDB.readPlan(planUID: planUID) {
                promise(.success(updatedPlan))
                print("PlanRepository, updatePlanIndex // Success : Plan 인덱스 업데이트 완료 - \(planUID) → \(newIndex)")
            } else {
                promise(.failure(PlanError.updateFailed))
                print("PlanRepository, updatePlanIndex // Exception : Plan 인덱스 업데이트 실패")
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
            
            var updatedPlans: [PlanModel] = []
            
            // ✅ 모든 Plan이 존재하는지 먼저 확인
            for planUID in planUIDs {
                if self.localDB.readPlan(planUID: planUID) == nil {
                    promise(.failure(PlanError.planNotFound))
                    print("PlanRepository, reorderPlans // Warning : Plan을 찾을 수 없음 - \(planUID)")
                    return
                }
            }
            
            // ✅ planUIDs 순서대로 index 0, 1, 2... 업데이트
            for (newIndex, planUID) in planUIDs.enumerated() {
                let success = self.localDB.updatePlanIndex(planUID: planUID, newIndex: newIndex)
                
                if success, let updatedPlan = self.localDB.readPlan(planUID: planUID) {
                    updatedPlans.append(updatedPlan)
                } else {
                    promise(.failure(PlanError.reorderFailed))
                    print("PlanRepository, reorderPlans // Exception : Plan 순서 변경 실패")
                    return
                }
            }
            
            promise(.success(updatedPlans))
            print("PlanRepository, reorderPlans // Success : Plan 순서 변경 완료 - \(planUIDs.count)개")
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - File CRUD Operations (개선된 버전)
    
    func createFile(planUID: String, data: Data, fileName: String, fileType: String) -> AnyPublisher<FileModel, Error> {
        return Future<FileModel, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(FileError.operationFailed))
                return
            }
            
            print("PlanRepository, createFile // Info : 파일 생성 시작 - \(fileName)")
            
            // ✅ Plan 존재 확인
            guard var existingPlan = self.localDB.readPlan(planUID: planUID) else {
                promise(.failure(FileError.fileNotFound)) // Plan을 찾을 수 없음
                print("PlanRepository, createFile // Warning : Plan을 찾을 수 없음 - \(planUID)")
                return
            }
            
            do {
                // ✅ 1. 파일 압축 (FileCompressionManager 사용)
                let compressedData = self.compressionManager.compressFile(data: data, fileType: fileType)
                print("PlanRepository, createFile // Info : 압축 완료 - 원본: \(data.count)bytes, 압축: \(compressedData.count)bytes")
                
                // ✅ 2. 고유 파일명 생성 (UUID 기반)
                let uniqueFileName = self.generateUniqueFileName(originalName: fileName, fileType: fileType, planUID: planUID)
                
                // ✅ 3. Documents/files 폴더에 저장
                let filePath = try self.saveFileToDocuments(data: compressedData, fileName: uniqueFileName)
                
                // ✅ 4. FileModel 생성
                let fileModel = FileModel(
                    fileName: fileName, // 원본 파일명 유지
                    fileType: fileType,
                    fileSize: Int64(data.count), // 원본 크기 저장
                    filePath: filePath,
                    createdDate: Date()
                )
                
                // ✅ 5. Plan의 files 배열에 추가하여 업데이트
                let updatedFiles = existingPlan.files + [fileModel]
                let updatedPlan = PlanModel(
                    uid: existingPlan.uid,
                    index: existingPlan.index,
                    memo: existingPlan.memo,
                    placeModel: existingPlan.placeModel,
                    files: updatedFiles
                )
                
                let success = self.localDB.updatePlan(updatedPlan)
                
                if success {
                    promise(.success(fileModel))
                    print("PlanRepository, createFile // Success : 파일 생성 완료 - \(fileName)")
                } else {
                    // 실패시 파일 시스템에서 롤백
                    try? self.fileManager.removeItem(atPath: filePath)
                    promise(.failure(FileError.saveFailed))
                    print("PlanRepository, createFile // Exception : Plan 업데이트 실패")
                }
                
            } catch {
                promise(.failure(FileError.operationFailed))
                print("PlanRepository, createFile // Exception : 파일 저장 실패 - \(error.localizedDescription)")
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
            
            // ✅ 모든 Plan에서 해당 file ID 검색
            let allPlans = self.getAllPlans()
            
            for plan in allPlans {
                if let file = plan.files.first(where: { $0.id.uuidString == fileUID }) {
                    promise(.success(file))
                    print("PlanRepository, readFile // Success : 파일 조회 완료 - \(fileUID)")
                    return
                }
            }
            
            promise(.failure(FileError.fileNotFound))
            print("PlanRepository, readFile // Warning : 파일을 찾을 수 없음 - \(fileUID)")
        }
        .eraseToAnyPublisher()
    }
    
    func readFiles(planUID: String) -> AnyPublisher<[FileModel], Error> {
        return Future<[FileModel], Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(FileError.operationFailed))
                return
            }
            
            guard let plan = self.localDB.readPlan(planUID: planUID) else {
                promise(.failure(FileError.fileNotFound)) // Plan을 찾을 수 없음
                print("PlanRepository, readFiles // Warning : Plan을 찾을 수 없음 - \(planUID)")
                return
            }
            
            promise(.success(plan.files))
            print("PlanRepository, readFiles // Success : 파일 목록 조회 완료 - \(plan.files.count)개")
        }
        .eraseToAnyPublisher()
    }
    
    func updateFile(fileUID: String, newFileName: String) -> AnyPublisher<FileModel, Error> {
        return Future<FileModel, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(FileError.operationFailed))
                return
            }
            
            // ✅ 파일이 속한 Plan 찾기
            let allPlans = self.getAllPlans()
            
            for var plan in allPlans {
                if let fileIndex = plan.files.firstIndex(where: { $0.id.uuidString == fileUID }) {
                    let oldFile = plan.files[fileIndex]
                    
                    // ✅ FileModel 업데이트 (fileName만 변경, 실제 파일 시스템 파일은 그대로)
                    let updatedFile = FileModel(
                        fileName: newFileName, // 새로운 파일명
                        fileType: oldFile.fileType,
                        fileSize: oldFile.fileSize,
                        filePath: oldFile.filePath, // 실제 파일 경로는 그대로
                        createdDate: oldFile.createdDate
                    )
                    
                    // ✅ Plan의 files 배열 업데이트
                    var updatedFiles = plan.files
                    updatedFiles[fileIndex] = updatedFile
                    
                    let updatedPlan = PlanModel(
                        uid: plan.uid,
                        index: plan.index,
                        memo: plan.memo,
                        placeModel: plan.placeModel,
                        files: updatedFiles
                    )
                    
                    let success = self.localDB.updatePlan(updatedPlan)
                    
                    if success {
                        promise(.success(updatedFile))
                        print("PlanRepository, updateFile // Success : 파일명 업데이트 완료 - \(newFileName)")
                    } else {
                        promise(.failure(FileError.operationFailed))
                        print("PlanRepository, updateFile // Exception : Plan 업데이트 실패")
                    }
                    return
                }
            }
            
            promise(.failure(FileError.fileNotFound))
            print("PlanRepository, updateFile // Warning : 파일을 찾을 수 없음 - \(fileUID)")
        }
        .eraseToAnyPublisher()
    }
    
    func deleteFile(fileUID: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(FileError.operationFailed))
                return
            }
            
            // ✅ 파일이 속한 Plan 찾기
            let allPlans = self.getAllPlans()
            
            for var plan in allPlans {
                if let fileIndex = plan.files.firstIndex(where: { $0.id.uuidString == fileUID }) {
                    let fileToDelete = plan.files[fileIndex]
                    
                    // ✅ 파일 시스템에서 삭제
                    self.deleteFileFromSystem(filePath: fileToDelete.filePath)
                    
                    // ✅ Plan의 files 배열에서 제거
                    var updatedFiles = plan.files
                    updatedFiles.remove(at: fileIndex)
                    
                    let updatedPlan = PlanModel(
                        uid: plan.uid,
                        index: plan.index,
                        memo: plan.memo,
                        placeModel: plan.placeModel,
                        files: updatedFiles
                    )
                    
                    let success = self.localDB.updatePlan(updatedPlan)
                    
                    if success {
                        promise(.success(()))
                        print("PlanRepository, deleteFile // Success : 파일 삭제 완료 - \(fileUID)")
                    } else {
                        promise(.failure(FileError.deleteFailed))
                        print("PlanRepository, deleteFile // Exception : Plan 업데이트 실패")
                    }
                    return
                }
            }
            
            promise(.failure(FileError.fileNotFound))
            print("PlanRepository, deleteFile // Warning : 파일을 찾을 수 없음 - \(fileUID)")
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Methods
    
    /// 디렉토리 설정
    private func setupFileDirectories() {
        let filesDirectory = documentsDirectory.appendingPathComponent("files")
        
        do {
            try fileManager.createDirectory(at: filesDirectory, withIntermediateDirectories: true)
            print("PlanRepository, setupFileDirectories // Success : files 디렉토리 생성")
        } catch {
            print("PlanRepository, setupFileDirectories // Warning : 디렉토리 생성 실패 - \(error.localizedDescription)")
        }
    }
    
    /// 고유 파일명 생성 (UUID 기반)
    private func generateUniqueFileName(originalName: String, fileType: String, planUID: String) -> String {
        let uuid = UUID().uuidString.prefix(8)
        let sanitizedName = originalName.replacingOccurrences(of: " ", with: "_")
        return "\(planUID)_\(uuid)_\(sanitizedName).\(fileType)"
    }
    
    /// Documents/files에 파일 저장
    private func saveFileToDocuments(data: Data, fileName: String) throws -> String {
        let fileURL = documentsDirectory.appendingPathComponent("files").appendingPathComponent(fileName)
        try data.write(to: fileURL)
        return fileURL.path
    }
    
    /// 파일 시스템에서 파일 삭제
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
    
    /// 삭제된 파일들 정리
    private func cleanupRemovedFiles(existingPlan: PlanModel, newPlan: PlanModel) {
        let newFileIDs = Set(newPlan.files.map { $0.id.uuidString })
        let removedFiles = existingPlan.files.filter { !newFileIDs.contains($0.id.uuidString) }
        
        for file in removedFiles {
            deleteFileFromSystem(filePath: file.filePath)
            print("PlanRepository, cleanupRemovedFiles // Info : 제거된 파일 삭제 - \(file.fileName)")
        }
    }
    
    /// Plan의 모든 파일 삭제
    private func deleteAllPlanFiles(_ plan: PlanModel) {
        for file in plan.files {
            deleteFileFromSystem(filePath: file.filePath)
            print("PlanRepository, deleteAllPlanFiles // Info : 파일 삭제 - \(file.fileName)")
        }
    }
    
    /// 모든 Plan 조회 (파일 검색용)
    private func getAllPlans() -> [PlanModel] {
        // TODO: LocalDB에 readAllPlans 메서드 추가 필요
        // 임시로 빈 배열 반환
        return []
    }
    
    deinit {
        print("PlanRepository, deinit // Success : Repository 해제 완료")
    }
}



//
//  FileCRUD.swift
//  HiRoute
//
//  Created by Jupond on 12/31/25.
//
import SwiftUI
import Combine

struct FileCRUD {
    private weak var vm: PlanVM?
    
    init(vm: PlanVM) {
        self.vm = vm
    }
    
    // MARK: - File CRUD Operations
    
    /**
     * 파일 생성 (단일 파일)
     */
    func create(planUID: String, files: [FileModel] = [], data: Data? = nil, fileName: String? = nil, fileType: String? = nil) {
        print("FileCRUD, create // Info : 파일 생성 시작")
        guard let vm = vm else { return }
        
        vm.setFileUploading(true)
        vm.updateFileUploadProgress(0.0)
               
        let fileDataList: [(Data, String, String)]
        
        if let data = data, let fileName = fileName, let fileType = fileType {
            // 단일 파일 생성
            fileDataList = [(data, fileName, fileType)]
            print("FileCRUD, create // Info : 단일 파일 생성 - \(fileName)")
        } else if !files.isEmpty {
            // 다중 파일 생성
            fileDataList = files.compactMap { file in
                guard let data = file.data else { return nil }
                return (data, file.fileName, file.fileType)
            }
            print("FileCRUD, create // Info : 다중 파일 생성 - \(files.count)개")
        } else {
            print("FileCRUD, create // Warning : 생성할 파일이 없음")
            vm.setFileUploading(false)
            return
        }
               
        guard !fileDataList.isEmpty else {
            print("FileCRUD, create // Warning : 유효한 파일 데이터가 없음")
            vm.setFileUploading(false)
            return
        }
               
        let createPublisher: AnyPublisher<[FileModel], Error>
               
        if fileDataList.count == 1 {
            let (data, fileName, fileType) = fileDataList[0]
            createPublisher = vm.planService.attachFile(planUID: planUID, data: data, fileName: fileName, fileType: fileType)
                .map { [$0] }
                .eraseToAnyPublisher()
        } else {
            createPublisher = vm.planService.attachMultipleFiles(planUID: planUID, fileDataList: fileDataList)
        }
               
        createPublisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak vm] completion in
                    vm?.setFileUploading(false)
                    vm?.updateFileUploadProgress(0.0)
                    
                    switch completion {
                    case .finished:
                        print("FileCRUD, create // Success : 파일 생성 완료")
                        
                    case .failure(let error):
                        vm?.handleError(error)
                        print("FileCRUD, create // Exception : 파일 생성 실패 - \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak vm] savedFiles in
                    addSavedFilesToList(savedFiles)  // ✅ private 메서드 호출
                    print("FileCRUD, create // Success : 파일 로컬 업데이트 완료 - \(savedFiles.count)개")
                }
            )
            .store(in: &vm.cancellables)
    }
        
  
    /**
     * 파일 조회 (단일 파일)
     */
    func read(fileUID: String) {
        guard let vm = vm else { return }
        
        print("FileCRUD, read // Info : 단일 파일 조회 - \(fileUID)")
        
        let readFilePublisher: AnyPublisher<FileModel, Error> = vm.planService.getFile(fileUID: fileUID)
        
        readFilePublisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("FileCRUD, read // Success : 단일 파일 조회 완료")
                        
                    case .failure(let error):
                        vm.handleError(error)
                        print("FileCRUD, read // Exception : 단일 파일 조회 실패 - \(error.localizedDescription)")
                    }
                },
                receiveValue: { file in
                    
                    print("FileCRUD, read // Success : 파일 조회 결과 - \(file.fileName)")
                }
            )
            .store(in: &vm.cancellables)
    }
    
    func readAll(planUID: String){
        guard let vm = vm else { return }

        print("FileCRUD, read // Info : Plan 파일 목록 조회 - \(planUID)")
        
        let readFilesPublisher: AnyPublisher<[FileModel], Error> = vm.planService.getAttachedFiles(planUID: planUID)
        
        readFilesPublisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("FileCRUD, read // Success : 파일 목록 조회 완료")
                        
                    case .failure(let error):
                        vm.handleError(error)
                        print("FileCRUD, read // Exception : 파일 목록 조회 실패 - \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak vm] attachedFiles in
                    vm?.updateSavedFilesForPlan(planUID: planUID, files: attachedFiles)
                    print("FileCRUD, read // Success : 파일 목록 업데이트 완료 - \(attachedFiles.count)개")
                }
            )
            .store(in: &vm.cancellables)
    }
    
    /**
     * 파일 수정 (파일명 변경)
     */
    func update(fileUID: String, newFileName: String) {
        print("FileCRUD, update // Info : 파일 수정 - \(fileUID) → \(newFileName)")
        guard let vm = vm else { return }
        
        vm.setLoading(true)
        
        let updateFilePublisher: AnyPublisher<FileModel, Error> = vm.planService.renameFile(
            fileUID: fileUID,
            newFileName: newFileName
        )
        
        updateFilePublisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak vm] completion in
                    vm?.setLoading(false)
                    
                    switch completion {
                    case .finished:
                        print("FileCRUD, update // Success : 파일 수정 완료")
                        
                    case .failure(let error):
                        vm?.handleError(error)
                        print("FileCRUD, update // Exception : 파일 수정 실패 - \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak vm] updatedFile in
                    updateFileInList(updatedFile)
                    print("FileCRUD, update // Success : 파일 로컬 업데이트 완료 - \(updatedFile.fileName)")
                }
            )
            .store(in: &vm.cancellables)
    }
    
    /**
     * 파일 삭제
     */
    func delete(fileUID: String) {
        print("FileCRUD, delete // Info : 파일 삭제 - \(fileUID)")
        guard let vm = vm else { return }
        
        let backupFiles = vm.files
        
        // 낙관적 업데이트: 로컬에서 먼저 제거
        vm.files.removeAll { $0.id.uuidString == fileUID }
        vm.setLoading(true)
        
        let deleteFilePublisher: AnyPublisher<Void, Error> = vm.planService.removeFile(fileUID: fileUID)
        
        deleteFilePublisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak vm] completion in
                    vm?.setLoading(false)
                    
                    switch completion {
                    case .finished:
                        print("FileCRUD, delete // Success : 파일 삭제 완료")
                        
                    case .failure(let error):
                        // 실패시 백업 데이터로 롤백
                        vm?.files = backupFiles
                        vm?.handleError(error)
                        print("FileCRUD, delete // Exception : 파일 삭제 실패, 롤백 - \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak vm] _ in
                    print("FileCRUD, delete // Success : 파일 삭제 서버 동기화 완료")
                }
            )
            .store(in: &vm.cancellables)
    }
    // MARK: - ✅ Helper Methods
    
    
    private func getPendingFiles() -> [FileModel] {
        guard let vm = vm else { return [] }
        return vm.files.filter { $0.isPendingUpload }
    }
    
    private func getSavedFiles() -> [FileModel] {
        guard let vm = vm else { return [] }
        return vm.files.filter { $0.isSaved }
    }
    
    func getFileCount(for planUID: String) -> Int {
        return getSavedFiles().filter { $0.filePath.contains(planUID) }.count
    }
    
    func getTotalPendingFileSize() -> Int64 {
        return getPendingFiles().reduce(0) { $0 + $1.fileSize }
    }
    
    func getFileCountByType() -> [String: Int] {
        guard let vm = vm else { return [:] }
        
        var typeCounts: [String: Int] = [:]
        for file in vm.files {
            let type = file.fileType.lowercased()
            typeCounts[type] = (typeCounts[type] ?? 0) + 1
        }
        return typeCounts
    }
    
    // MARK: - Private File List Management
    
    private func addSavedFileToList(_ savedFile: FileModel) {
        guard let vm = vm else { return }
        
        let fileModel = FileModel.saved(
            fileName: savedFile.fileName,
            fileType: savedFile.fileType,
            fileSize: savedFile.fileSize,
            filePath: savedFile.filePath,
            createdDate: savedFile.createdDate
        )
        vm.files.append(fileModel)
    }
    
    private func addSavedFilesToList(_ savedFiles: [FileModel]) {
        guard let vm = vm else { return }
        
        let fileModels = savedFiles.map { file in
            FileModel.saved(
                fileName: file.fileName,
                fileType: file.fileType,
                fileSize: file.fileSize,
                filePath: file.filePath,
                createdDate: file.createdDate
            )
        }
        vm.files.append(contentsOf: fileModels)
    }
       
    
    private func addMultipleSavedFilesToList(_ savedFiles: [FileModel]) {
        guard let vm = vm else { return }
        
        // 저장된 파일들 추가
        let fileModels = savedFiles.map { file in
            FileModel.saved(
                fileName: file.fileName,
                fileType: file.fileType,
                fileSize: file.fileSize,
                filePath: file.filePath,
                createdDate: file.createdDate
            )
        }
        vm.files.append(contentsOf: fileModels)
    }

    
    private func updateFileInList(_ updatedFile: FileModel) {
        guard let vm = vm else { return }
        
        if let index = vm.files.firstIndex(where: { $0.id.uuidString == updatedFile.id.uuidString }) {
            let savedFile = FileModel.saved(
                fileName: updatedFile.fileName,
                fileType: updatedFile.fileType,
                fileSize: updatedFile.fileSize,
                filePath: updatedFile.filePath,
                createdDate: updatedFile.createdDate
            )
            vm.files[index] = savedFile
        }
    }
}

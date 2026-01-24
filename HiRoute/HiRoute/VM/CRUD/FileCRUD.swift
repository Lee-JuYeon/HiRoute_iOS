//
//  FileCRUD.swift
//  HiRoute
//
//  Created by Jupond on 12/31/25.
//
import SwiftUI
import Combine

struct FileCRUD {
    private weak var vm: ScheduleVM?
    
    init(vm: ScheduleVM) {
        self.vm = vm
    }
    
    // MARK: - File CRUD Operations
    
    /**
     * 파일 생성 (단일 파일)
     */
    func create(planUID: String, files: [FileModel] = [], data: Data? = nil, fileName: String? = nil, fileType: String? = nil) {
        print("FileCRUD, create // Info : 파일 생성 시작")
        guard let vm = vm else { return }
        
        vm.setLoading(true)
        vm.setProgress(0.0)
               
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
            vm.setLoading(false)
            return
        }
               
        guard !fileDataList.isEmpty else {
            print("FileCRUD, create // Warning : 유효한 파일 데이터가 없음")
            vm.setLoading(false)
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
                    vm?.setLoading(false)
                    vm?.setProgress(0.0)
                    
                    switch completion {
                    case .finished:
                        print("FileCRUD, create // Success : 파일 생성 완료")
                        
                    case .failure(let error):
                        vm?.handleError(error)
                        print("FileCRUD, create // Exception : 파일 생성 실패 - \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak vm] savedFiles in
                    vm?.updateFiles(planUID: planUID, newFiles: savedFiles) // ✅ 새 메서드 사용
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
        
        vm.planService.getFile(fileUID: fileUID)
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
                    vm?.updateFiles(planUID: planUID, newFiles: attachedFiles)
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
        
        guard let planUID = findPlanUID(for: fileUID, in: vm.currentPlans) else {
            print("FileCRUD, update // Error : 파일이 속한 Plan을 찾을 수 없음")
            return
        }
        
        vm.setLoading(true)
        
        vm.planService.renameFile(fileUID: fileUID, newFileName: newFileName)
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
                    vm?.readAllFiles(planUID: planUID)
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
        
        // 해당 파일이 속한 Plan 찾기
        guard let planUID = findPlanUID(for: fileUID, in: vm.currentPlans) else {
            print("FileCRUD, delete // Error : 파일이 속한 Plan을 찾을 수 없음")
            return
        }
        
        vm.setLoading(true)
                
        vm.planService.removeFile(fileUID: fileUID)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak vm] completion in
                    vm?.setLoading(false)
                    
                    switch completion {
                    case .finished:
                        print("FileCRUD, delete // Success : 파일 삭제 완료")
                        
                    case .failure(let error):
                        vm?.handleError(error)
                        print("FileCRUD, delete // Exception : 파일 삭제 실패, 롤백 - \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak vm] _ in
                    vm?.readAllFiles(planUID: planUID)
                    print("FileCRUD, delete // Success : 파일 삭제 서버 동기화 완료")
                }
            )
            .store(in: &vm.cancellables)
    }

    private func findPlanUID(for fileUID: String, in plans: [PlanModel]) -> String? {
        return plans.first { plan in
            plan.files.contains { $0.id.uuidString == fileUID }
        }?.uid
    }
        
 
    func getFileCount(for planUID: String) -> Int {
        guard let vm = vm else { return 0 }
        return vm.getFilesForPlan(planUID: planUID).count // ✅ 기존 computed property 활용
    }
    
    func getTotalFileSize() -> Int64 {
        guard let vm = vm else { return 0 }
        return vm.currentFiles.reduce(0) { $0 + $1.fileSize } // ✅ computed property 활용
    }

    
    func getFileCountByType() -> [String: Int] {
        guard let vm = vm else { return [:] }
        
        var typeCounts: [String: Int] = [:]
        for file in vm.currentFiles {
            let type = file.fileType.lowercased()
            typeCounts[type] = (typeCounts[type] ?? 0) + 1
        }
        return typeCounts
    }
    

}

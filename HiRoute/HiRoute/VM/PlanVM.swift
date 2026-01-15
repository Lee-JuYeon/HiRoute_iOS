//
//  PlanVM.swift
//  HiRoute
//
//  Created by Jupond on 12/3/25.
//
import Combine
//import SwiftUI
//
//class PlanVM: ObservableObject {
//    
//    // MARK: - Published Properties
//    @Published var currentPlanList: [PlanModel] = []
//    @Published var currentPlan: PlanModel?
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//    
//    @Published var files: [FileModel] = []
//    @Published var isUploadingFile = false
//    @Published var fileUploadProgress: Double = 0.0
//    
//    // MARK: - Dependencies & Components
//    internal let planService: PlanService
//    internal var cancellables = Set<AnyCancellable>()
//  
//    
//    init(planService: PlanService) {
//        self.planService = planService
//        print("PlanVM, init // Success : PlanService 연결 완료")
//    }
//        
//    internal func setLoading(_ loading: Bool) {
//        isLoading = loading
//    }
//    
//    internal func setFileUploading(_ uploading: Bool) {
//        isUploadingFile = uploading
//    }
//    
//    internal func updateFileUploadProgress(_ progress: Double) {
//        fileUploadProgress = progress
//    }
//    
//    internal func handleError(_ error: Error) {
//        if let planError = error as? PlanError {
//            errorMessage = planError.localizedDescription
//        } else if let fileError = error as? FileError {
//            errorMessage = fileError.localizedDescription
//        } else if let scheduleError = error as? ScheduleError {
//            errorMessage = scheduleError.localizedDescription
//        } else {
//            errorMessage = error.localizedDescription
//        }
//    }
//    
//    internal func updateSavedFilesForPlan(planUID: String, files: [FileModel]) {
//        
//        // 해당 Plan의 기존 파일들 제거
//        self.files.removeAll { $0.isSaved && $0.filePath.contains(planUID) }
//        
//        // 새로운 파일들 추가
//        let savedFiles = files.map { file in
//            FileModel.saved(
//                fileName: file.fileName,
//                fileType: file.fileType,
//                fileSize: file.fileSize,
//                filePath: file.filePath,
//                createdDate: file.createdDate
//            )
//        }
//        self.files.append(contentsOf: savedFiles)
//    }
//    
//    internal func updateSavedFilesFromPlan(_ plan: PlanModel) {
//               
//        self.files.removeAll { $0.isPendingUpload }
//        
//        let savedFileModels = plan.files.map { file in
//            FileModel.saved(
//                fileName: file.fileName,
//                fileType: file.fileType,
//                fileSize: file.fileSize,
//                filePath: file.filePath,
//                createdDate: file.createdDate
//            )
//        }
//        self.files.append(contentsOf: savedFileModels)
//        print("FileCRUD, updateSavedFilesFromPlan // Success : 저장된 파일 업데이트 완료 - \(savedFileModels.count)개")
//    }
//    
//    func createPlan(placeModel: PlaceModel, scheduleUID: String, files: [FileModel]) {
//        planCRUD.create(placeModel,scheduleUID: scheduleUID, files: files)
//    }
//    
//    func readPlan(planUID: String) {
//        planCRUD.read(uid: planUID)
//    }
//    
//    func readAllPlans(scheduleUID: String) {
//        planCRUD.readAll(scheduleUID: scheduleUID)
//    }
//    
//    func updatePlan(_ plan: PlanModel) {
//        planCRUD.update(plan)
//    }
//    
//    func updateIndex(from: Int, to: Int) {
//        planCRUD.updateIndex(from: from, to: to)
//    }
//    
//    func updatePlanMemo(planUID: String, newMemo: String) {
//        planCRUD.updateMemo(planUID: planUID, newMemo: newMemo)
//    }
//    
//    func deletePlan(planUID: String) {
//        planCRUD.delete(planUID: planUID)
//    }
//        
//    func createFile(planUID: String, data: Data? = nil, fileName: String? = nil, fileType: String? = nil, files: [FileModel] = []) {
//        // ✅ 단일 메서드로 통합 (FileCRUD.create와 동일한 시그니처)
//        fileCRUD.create(planUID: planUID, files: files, data: data, fileName: fileName, fileType: fileType)
//    }
//       
//    
//    func readFile(fileUID: String) {
//        fileCRUD.read(fileUID: fileUID)
//    }
//    
//    func readAllFiles(planUID: String) {
//        fileCRUD.readAll(planUID: planUID)
//    }
//    
//    
//    func updateFile(fileUID: String, newFileName: String) {
//        fileCRUD.update(fileUID: fileUID, newFileName: newFileName)
//    }
//    
//    func deleteFile(fileUID: String) {
//        fileCRUD.delete(fileUID: fileUID)
//    }
//    
//    deinit {
//        cancellables.removeAll()
//        print("PlanVM, deinit // Success : ViewModel 해제 완료")
//    }
//}

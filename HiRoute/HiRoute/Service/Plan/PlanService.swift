//
//  ScheduleUpdateManager.swift
//  HiRoute
//
//  Created by Jupond on 12/5/25.
//
import Foundation
import Combine

/**
 * PlanService
 * - Plan 도메인의 비즈니스 로직 담당
 * - Schedule과 Place를 연결하는 중간 역할
 * - 방문장소의 순서 관리 및 메모 관리
 */
class PlanService {
    
    // MARK: - Dependencies
    private let planRepository: PlanProtocol & FileProtocol
    
    // MARK: - Reactive
    private var cancellables = Set<AnyCancellable>()
    
    init(planRepository: PlanProtocol & FileProtocol) {
        self.planRepository = planRepository
        print("PlanService, init // Success : Repository 연결 완료")
    }
    
    // MARK: - Standard CRUD Operations
    
    func createPlan(_ plan: PlanModel, scheduleUID: String, fileList: [(Data, String, String)] = []) -> AnyPublisher<PlanModel, Error> {
        print("PlanService, createPlan // Info : Plan 생성 시작 - \(plan.placeModel.title)")
               
        return Just(plan)
            .tryMap { [weak self] planModel in
                guard let self = self else {
                    throw PlanError.unknown
                }
                try self.validatePlan(planModel).get()
                return planModel
            }
            .flatMap { [weak self] validatedPlan -> AnyPublisher<PlanModel, Error> in
                guard let self = self else {
                    return Fail<PlanModel, Error>(error: PlanError.unknown).eraseToAnyPublisher()
                }
                
                if fileList.isEmpty {
                    return self.createBasicPlan(validatedPlan, scheduleUID: scheduleUID)
                } else {
                    return self.createPlanWithFiles(validatedPlan, scheduleUID: scheduleUID, fileList: fileList)
                }
            }
            .handleEvents(
                receiveOutput: { planModel in
                    print("PlanService, createPlan // Success : Plan 생성 완료 - \(planModel.placeModel.title)")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("PlanService, createPlan // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    private func createBasicPlan(_ plan: PlanModel, scheduleUID: String) -> AnyPublisher<PlanModel, Error> {
        return planRepository.createPlan(plan, scheduleUID: scheduleUID)
            .eraseToAnyPublisher()
    }
    
    private func createPlanWithFiles(_ plan: PlanModel, scheduleUID: String, fileList: [(Data, String, String)]) -> AnyPublisher<PlanModel, Error> {
        return planRepository.createPlan(plan, scheduleUID: scheduleUID)
            .flatMap { [weak self] createdPlan -> AnyPublisher<PlanModel, Error> in
                guard let self = self else {
                    return Fail<PlanModel, Error>(error: PlanError.unknown).eraseToAnyPublisher()
                }
                
                return self.attachMultipleFiles(planUID: createdPlan.uid, fileDataList: fileList)
                    .map { _ in createdPlan }
                    .catch { [weak self] error -> AnyPublisher<PlanModel, Error> in
                        guard let self = self else {
                            return Fail<PlanModel, Error>(error: PlanError.unknown).eraseToAnyPublisher()
                        }
                        
                        print("PlanService, createPlanWithFiles // Exception : 파일 첨부 실패, Plan 롤백")
                        return self.planRepository.deletePlan(planUID: createdPlan.uid)
                            .flatMap { _ in
                                Fail<PlanModel, Error>(error: error).eraseToAnyPublisher()
                            }
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func readPlan(planUID: String) -> AnyPublisher<PlanModel, Error> {
        print("PlanService, readPlan // Info : Plan 조회 - \(planUID)")
        
        return planRepository.readPlan(planUID: planUID)
            .handleEvents(
                receiveOutput: { planModel in
                    print("PlanService, readPlan // Success : Plan 조회 완료 - \(planModel.placeModel.title)")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("PlanService, readPlan // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    func readPlanList(scheduleUID: String) -> AnyPublisher<[PlanModel], Error> {
        print("PlanService, readPlanList // Info : Plan 목록 조회 - \(scheduleUID)")
        
        return planRepository.readPlanList(scheduleUID: scheduleUID)
            .map { planModels in
                planModels.sorted { $0.index < $1.index }
            }
            .handleEvents(
                receiveOutput: { planModels in
                    print("PlanService, readPlanList // Success : Plan 목록 조회 완료 - \(planModels.count)개")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("PlanService, readPlanList // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    func updatePlan(_ plan: PlanModel) -> AnyPublisher<PlanModel, Error> {
        print("PlanService, updatePlan // Info : Plan 업데이트 - \(plan.placeModel.title)")
        
        return Just(plan)
            .tryMap { [weak self] planModel in
                guard let self = self else {
                    throw PlanError.unknown
                }
                try self.validatePlan(planModel).get()
                return planModel
            }
            .flatMap { [weak self] validatedPlan -> AnyPublisher<PlanModel, Error> in
                guard let self = self else {
                    return Fail<PlanModel, Error>(error: PlanError.unknown).eraseToAnyPublisher()
                }
                
                return self.planRepository.updatePlan(validatedPlan)
            }
            .handleEvents(
                receiveOutput: { planModel in
                    print("PlanService, updatePlan // Success : Plan 업데이트 완료 - \(planModel.placeModel.title)")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("PlanService, updatePlan // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    func deletePlan(planUID: String) -> AnyPublisher<Void, Error> {
        print("PlanService, deletePlan // Info : Plan 삭제 - \(planUID)")
        
        return planRepository.deletePlan(planUID: planUID)
            .handleEvents(
                receiveOutput: { _ in
                    print("PlanService, deletePlan // Success : Plan 삭제 완료 - \(planUID)")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("PlanService, deletePlan // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    // MARK: - Plan Domain Business Logic
    
    func updatePlanMemo(planUID: String, memo: String) -> AnyPublisher<PlanModel, Error> {
        print("PlanService, updatePlanMemo // Info : Plan 메모 업데이트 - \(planUID)")
        
        return planRepository.updatePlanMemo(planUID: planUID, memo: memo)
            .handleEvents(
                receiveOutput: { _ in
                    print("PlanService, updatePlanMemo // Success : Plan 메모 업데이트 완료 - \(planUID)")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("PlanService, updatePlanMemo // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    func updatePlanIndex(planUID: String, newIndex: Int) -> AnyPublisher<PlanModel, Error> {
        print("PlanService, updatePlanIndex // Info : Plan 인덱스 업데이트 - \(planUID) → \(newIndex)")
        
        return planRepository.updatePlanIndex(planUID: planUID, newIndex: newIndex)
            .handleEvents(
                receiveOutput: { _ in
                    print("PlanService, updatePlanIndex // Success : Plan 인덱스 업데이트 완료 - \(planUID)")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("PlanService, updatePlanIndex // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    func reorderPlans(planUIDs: [String]) -> AnyPublisher<[PlanModel], Error> {
        print("PlanService, reorderPlans // Info : Plan 순서 재정렬 - \(planUIDs.count)개")
        
        return planRepository.reorderPlans(planUIDs: planUIDs)
            .handleEvents(
                receiveOutput: { planModels in
                    print("PlanService, reorderPlans // Success : Plan 순서 재정렬 완료 - \(planModels.count)개")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("PlanService, reorderPlans // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    // MARK: - File Operations
    
    func attachFile(planUID: String, data: Data, fileName: String, fileType: String) -> AnyPublisher<FileModel, Error> {
        print("PlanService, attachFile // Info : 파일 첨부 - \(fileName) to \(planUID)")
        
        return Just((data, fileName, fileType))
            .tryMap { [weak self] (dataValue, fileNameValue, fileTypeValue) in
                guard let self = self else {
                    throw FileError.operationFailed
                }
                try self.validateFileData(data: dataValue, fileName: fileNameValue, fileType: fileTypeValue).get()
                return (dataValue, fileNameValue, fileTypeValue)
            }
            .flatMap { [weak self] (dataValue, fileNameValue, fileTypeValue) -> AnyPublisher<FileModel, Error> in
                guard let self = self else {
                    return Fail<FileModel, Error>(error: FileError.operationFailed).eraseToAnyPublisher()
                }
                
                return self.planRepository.createFile(planUID: planUID, data: dataValue, fileName: fileNameValue, fileType: fileTypeValue)
            }
            .handleEvents(
                receiveOutput: { fileModel in
                    print("PlanService, attachFile // Success : 파일 첨부 완료 - \(fileModel.fileName)")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("PlanService, attachFile // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    func attachMultipleFiles(planUID: String, fileDataList: [(Data, String, String)]) -> AnyPublisher<[FileModel], Error> {
        print("PlanService, attachMultipleFiles // Info : 다중 파일 첨부 - \(fileDataList.count)개 to \(planUID)")
        
        let filePublishers = fileDataList.compactMap { [weak self] (data, fileName, fileType) -> AnyPublisher<FileModel, Error>? in
            guard let self = self else { return nil }
            
            switch self.validateFileData(data: data, fileName: fileName, fileType: fileType) {
            case .success:
                return self.planRepository.createFile(planUID: planUID, data: data, fileName: fileName, fileType: fileType)
            case .failure(let error):
                return Fail<FileModel, Error>(error: error).eraseToAnyPublisher()
            }
        }
        
        return Publishers.Sequence(sequence: filePublishers)
            .flatMap(maxPublishers: .max(1)) { $0 }
            .collect()
            .handleEvents(
                receiveOutput: { fileModels in
                    print("PlanService, attachMultipleFiles // Success : 다중 파일 첨부 완료 - \(fileModels.count)개")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("PlanService, attachMultipleFiles // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    func getAttachedFiles(planUID: String) -> AnyPublisher<[FileModel], Error> {
        print("PlanService, getAttachedFiles // Info : 첨부 파일 조회 - \(planUID)")
        
        return planRepository.readFiles(planUID: planUID)
            .handleEvents(
                receiveOutput: { fileModels in
                    print("PlanService, getAttachedFiles // Success : 첨부 파일 조회 완료 - \(fileModels.count)개")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("PlanService, getAttachedFiles // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    func getFile(fileUID: String) -> AnyPublisher<FileModel, Error> {
        print("PlanService, getFile // Info : 파일 조회 - \(fileUID)")
        
        return planRepository.readFile(fileUID: fileUID)
            .handleEvents(
                receiveOutput: { fileModel in
                    print("PlanService, getFile // Success : 파일 조회 완료 - \(fileModel.fileName)")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("PlanService, getFile // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    func renameFile(fileUID: String, newFileName: String) -> AnyPublisher<FileModel, Error> {
        print("PlanService, renameFile // Info : 파일명 변경 - \(fileUID) → \(newFileName)")
        
        return Just(newFileName)
            .tryMap { [weak self] fileNameValue in
                guard let self = self else {
                    throw FileError.operationFailed
                }
                try self.validateFileName(fileNameValue).get()
                return fileNameValue
            }
            .flatMap { [weak self] validatedFileName -> AnyPublisher<FileModel, Error> in
                guard let self = self else {
                    return Fail<FileModel, Error>(error: FileError.operationFailed).eraseToAnyPublisher()
                }
                
                return self.planRepository.updateFile(fileUID: fileUID, newFileName: validatedFileName)
            }
            .handleEvents(
                receiveOutput: { fileModel in
                    print("PlanService, renameFile // Success : 파일명 변경 완료 - \(fileModel.fileName)")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("PlanService, renameFile // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    func removeFile(fileUID: String) -> AnyPublisher<Void, Error> {
        print("PlanService, removeFile // Info : 파일 삭제 - \(fileUID)")
        
        return planRepository.deleteFile(fileUID: fileUID)
            .handleEvents(
                receiveOutput: { _ in
                    print("PlanService, removeFile // Success : 파일 삭제 완료 - \(fileUID)")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("PlanService, removeFile // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    // MARK: - Validation Logic
    
    private func validatePlan(_ plan: PlanModel) -> Result<Void, PlanError> {
        if plan.uid.isEmpty {
            print("PlanService, validatePlan // Warning : Plan UID가 비어있음")
            return .failure(.saveFailed)
        }
        
        if plan.placeModel.uid.isEmpty {
            print("PlanService, validatePlan // Warning : Place UID가 비어있음")
            return .failure(.saveFailed)
        }
        
        return .success(())
    }
    
    private func validateFileData(data: Data, fileName: String, fileType: String) -> Result<Void, FileError> {
        switch validateFileName(fileName) {
        case .failure(let error):
            return .failure(error)
        case .success:
            break
        }
        
        let supportedTypes = ["jpg", "jpeg", "png", "gif", "pdf", "txt", "doc", "docx"]
        if !supportedTypes.contains(fileType.lowercased()) {
            print("PlanService, validateFileData // Warning : 지원하지 않는 파일 타입 - \(fileType)")
            return .failure(.unsupportedFileType)
        }
        
        if data.isEmpty {
            print("PlanService, validateFileData // Warning : 빈 파일")
            return .failure(.operationFailed)
        }
        
        return .success(())
    }
    
    private func validateFileName(_ fileName: String) -> Result<Void, FileError> {
        let trimmedName = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName.isEmpty {
            print("PlanService, validateFileName // Warning : 빈 파일명")
            return .failure(.operationFailed)
        }
        
        let forbiddenChars = CharacterSet(charactersIn: "/\\:*?\"<>|")
        if trimmedName.rangeOfCharacter(from: forbiddenChars) != nil {
            print("PlanService, validateFileName // Warning : 금지된 문자 포함 - \(fileName)")
            return .failure(.operationFailed)
        }
        
        return .success(())
    }
    
    deinit {
        cancellables.removeAll()
        print("PlanService, deinit // Success : Plan+File 서비스 해제 완료")
    }
}

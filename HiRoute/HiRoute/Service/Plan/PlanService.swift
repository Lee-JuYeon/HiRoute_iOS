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
    
    /**
     * 초기화
     * @param repository: VisitPlace 데이터 액세스 담당 Repository
     */
    init(
        planRepository: PlanProtocol & FileProtocol
    ) {
        self.planRepository = planRepository
        print("PlanService, init // Success : Repository 연결 완료")
    }
    
    // MARK: - Standard CRUD Operations
    
    /**
     * 새 방문장소 생성 (파일 처리 포함)
     * - 1. 파일들 먼저 FileService로 저장
     * - 2. VisitPlace Repository로 메타데이터 저장
     * - 파일 저장 실패시 전체 롤백
     * @param visitPlace: 생성할 방문장소 모델
     * @param fileDataList: 실제 파일 데이터들 (파일이 있는 경우)
     * @return: 생성된 방문장소 Publisher
     */
    func createPlan(_ plan: PlanModel, fileList: [(Data, String, String)] = []) -> AnyPublisher<PlanModel, Error> {
        print("PlanService, createPlan // Info : Plan 생성 시작 - \(plan.placeModel.title)")
               
        return Just(plan)
            .tryMap { [weak self] plan in
                try self?.validatePlan(plan).get()
                return plan
            }
            .flatMap { [weak self] validatedPlan -> AnyPublisher<PlanModel, Error> in
                guard let self = self else {
                    return Fail<PlanModel, Error>(error: PlanError.unknown)
                        .eraseToAnyPublisher()
                }
                
                // 파일 있는지 체크
                if fileList.isEmpty {
                    // 파일 없음: 기본 Plan 생성
                    return self.planRepository.createPlan(validatedPlan)
                } else {
                    // 파일 있음: Plan + 파일 동시 생성
                    return self.createPlanWithFiles(validatedPlan, fileList: fileList)
                }
            }
            .handleEvents(
                receiveOutput: { plan in
                    print("PlanService, createPlan // Success : Plan 생성 완료 - \(plan.placeModel.title)")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("PlanService, createPlan // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    /**
     * ✅ 파일과 함께 Plan 생성 (통합 생성)
     * - Plan 생성 후 여러 파일을 순차적으로 첨부
     * - 파일 첨부 실패시 Plan 삭제 롤백
     * @param plan: 생성할 Plan 모델
     * @param fileDataList: [(data, fileName, fileType)] 파일 데이터 목록
     * @return: 파일이 첨부된 완전한 Plan Publisher
     */
    private func createPlanWithFiles(_ plan: PlanModel, fileList: [(Data, String, String)]) -> AnyPublisher<PlanModel, Error> {
        return planRepository.createPlan(plan)
            .flatMap { [weak self] createdPlan -> AnyPublisher<PlanModel, Error> in
                guard let self = self else {
                    return Fail(error: PlanError.unknown).eraseToAnyPublisher()
                }
                
                // 파일들을 순차적으로 첨부
                return self.attachMultipleFiles(planUID: createdPlan.uid, fileDataList: fileList)
                    .map { _ in createdPlan } // 파일 첨부 성공시 원본 Plan 반환
                    .catch { [weak self] error -> AnyPublisher<PlanModel, Error> in
                        // 파일 첨부 실패시 Plan 삭제 (롤백)
                        print("PlanService, createPlanWithFilesInternal // Exception : 파일 첨부 실패, Plan 롤백")
                        
                        guard let self = self else {
                            return Fail(error: PlanError.unknown).eraseToAnyPublisher()
                        }
                        
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
       
    
    /**
     * 특정 방문장소 조회
     * - UID로 단일 방문장소 조회
     * - Place 정보와 첨부 File들도 함께 반환
     * @param uid: 조회할 방문장소 UID
     * @return: 조회된 방문장소 Publisher
     */
    func readPlan(planUID: String) -> AnyPublisher<PlanModel, Error> {
        print("PlanService, readPlan // Info : Plan 조회 - \(planUID)")
        
        return planRepository.readPlan(planUID: planUID)
            .handleEvents(
                receiveOutput: { plan in
                    print("PlanService, readPlan // Success : Plan 조회 완료 - \(plan.placeModel.title)")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("PlanService, readPlan // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    /**
     * 특정 일정의 모든 방문장소 조회
     * - Schedule에 속한 방문장소들을 방문 순서(index)대로 정렬하여 반환
     * - 여행 일정 상세보기에서 사용
     * @param scheduleUID: 일정 UID
     * @return: 정렬된 방문장소 목록 Publisher
     */
    func readPlanList(scheduleUID: String) -> AnyPublisher<[PlanModel], Error> {
        print("PlanService, readPlanList // Info : Plan 목록 조회 - \(scheduleUID)")
        
        return planRepository.readPlanList(scheduleUID: scheduleUID)
            .map { plans in
                // ✅ 비즈니스 로직: index 순서 보장
                return plans.sorted { $0.index < $1.index }
            }
            .handleEvents(
                receiveOutput: { plans in
                    print("PlanService, readPlanList // Success : Plan 목록 조회 완료 - \(plans.count)개")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("PlanService, readPlanList // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    /**
     * 방문장소 정보 수정
     * - memo, index, 첨부 파일 등 VisitPlace 속성 수정
     * - Place 기본 정보 변경은 PlaceService에서 처리
     * @param visitPlace: 수정된 방문장소 모델
     * @return: 수정된 방문장소 Publisher
     */
    func updatePlan(_ plan: PlanModel) -> AnyPublisher<PlanModel, Error> {
        print("PlanService, updatePlan // Info : Plan 업데이트 - \(plan.placeModel.title)")
        
        return Just(plan)
            .tryMap { [weak self] plan in
                try self?.validatePlan(plan).get()
                return plan
            }
            .flatMap { [weak self] validatedPlan in
                guard let self = self else {
                    return Fail<PlanModel, Error>(error: PlanError.unknown)
                        .eraseToAnyPublisher()
                }
                return self.planRepository.updatePlan(validatedPlan)
            }
            .handleEvents(
                receiveOutput: { plan in
                    print("PlanService, updatePlan // Success : Plan 업데이트 완료 - \(plan.placeModel.title)")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("PlanService, updatePlan // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
       
    
    /**
     * 방문장소 삭제
     * - Schedule에서 Place 제거
     * - 연결된 첨부 파일들도 함께 삭제됨
     * - Place 자체는 삭제되지 않음 (다른 Schedule에서 사용 가능)
     * @param uid: 삭제할 방문장소 UID
     * @return: 삭제 완료 Publisher
     */
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
    
    // MARK: - VisitPlace Domain Business Logic
    
    /**
     * 방문장소 메모 업데이트
     * - 특정 방문장소의 개인 메모만 수정하는 편의 메서드
     * - 여행 중 개인적인 메모나 후기 작성할 때 사용
     * @param uid: 수정할 방문장소 UID
     * @param memo: 새 메모 내용
     * @return: 수정된 방문장소 Publisher
     */
    func updatePlanMemo(planUID: String, memo: String) -> AnyPublisher<PlanModel, Error> {
        print("PlanService, updatePlanMemo // Info : Plan 메모 업데이트 - \(planUID)")
        
        return planRepository.updatePlanMemo(planUID: planUID, memo: memo)
            .handleEvents(
                receiveOutput: { plan in
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
    
    /**
     * 방문장소 순서 변경
     * - 특정 방문장소의 index만 변경하는 편의 메서드
     * - 드래그앤드롭으로 순서 변경할 때 사용
     * @param uid: 수정할 방문장소 UID
     * @param newIndex: 새로운 방문 순서
     * @return: 수정된 방문장소 Publisher
     */
    func updatePlanIndex(planUID: String, newIndex: Int) -> AnyPublisher<PlanModel, Error> {
        print("PlanService, updatePlanIndex // Info : Plan 인덱스 업데이트 - \(planUID) → \(newIndex)")
        
        return planRepository.updatePlanIndex(planUID: planUID, newIndex: newIndex)
            .handleEvents(
                receiveOutput: { plan in
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
    
    /**
     * 다중 방문장소 순서 재정렬
     * - UI에서 드래그앤드롭으로 여러 장소의 순서를 한번에 변경할 때 사용
     * - 각 VisitPlace의 index를 배열 순서에 맞게 업데이트
     * @param uids: 새로운 순서로 정렬된 VisitPlace UID 배열
     * @return: 재정렬된 방문장소 목록 Publisher
     */
    func reorderPlans(planUIDs: [String]) -> AnyPublisher<[PlanModel], Error> {
        print("PlanService, reorderPlans // Info : Plan 순서 재정렬 - \(planUIDs.count)개")
        
        return planRepository.reorderPlans(planUIDs: planUIDs)
            .handleEvents(
                receiveOutput: { plans in
                    print("PlanService, reorderPlans // Success : Plan 순서 재정렬 완료 - \(plans.count)개")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("PlanService, reorderPlans // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    /**
     * Plan에 파일 첨부
     * - 기존 Plan에 새로운 파일을 추가
     * - 파일 압축 및 고유명 생성은 Repository에서 처리
     * @param planUID: 파일을 첨부할 Plan UID
     * @param data: 파일 바이너리 데이터
     * @param fileName: 원본 파일명
     * @param fileType: 파일 확장자
     * @return: 생성된 FileModel Publisher
     */
    func attachFile(planUID: String, data: Data, fileName: String, fileType: String) -> AnyPublisher<FileModel, Error> {
        print("PlanService, attachFile // Info : 파일 첨부 - \(fileName) to \(planUID)")
        
        return Just((data, fileName, fileType))
            .tryMap { [weak self] (data, fileName, fileType) in
                try self?.validateFileData(data: data, fileName: fileName, fileType: fileType).get()
                return (data, fileName, fileType)
            }
            .flatMap { [weak self] (data, fileName, fileType) in
                guard let self = self else {
                    return Fail<FileModel, Error>(error: FileError.operationFailed)
                        .eraseToAnyPublisher()
                }
                return self.planRepository.createFile(planUID: planUID, data: data, fileName: fileName, fileType: fileType)
            }
            .handleEvents(
                receiveOutput: { file in
                    print("PlanService, attachFile // Success : 파일 첨부 완료 - \(file.fileName)")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("PlanService, attachFile // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    /**
     * ✅ 여러 파일 일괄 첨부
     * - 여러 파일을 순차적으로 첨부
     * - 하나라도 실패시 전체 실패 (원자성 보장 안함, UI에서 부분 성공 처리)
     * @param planUID: 파일들을 첨부할 Plan UID
     * @param fileDataList: [(data, fileName, fileType)] 파일 데이터 목록
     * @return: 생성된 FileModel 목록 Publisher
     */
    func attachMultipleFiles(planUID: String, fileDataList: [(Data, String, String)]) -> AnyPublisher<[FileModel], Error> {
        print("PlanService, attachMultipleFiles // Info : 다중 파일 첨부 - \(fileDataList.count)개 to \(planUID)")
        
        let filePublishers = fileDataList.map { (data, fileName, fileType) in
            attachFile(planUID: planUID, data: data, fileName: fileName, fileType: fileType)
        }
        
        // ✅ 순차적 처리: 파일들을 하나씩 차례로 첨부
        return filePublishers.reduce(
            Just<[FileModel]>([]).setFailureType(to: Error.self).eraseToAnyPublisher()
        ) { accumulated, filePublisher in
            accumulated.flatMap { files in
                filePublisher.map { files + [$0] }
            }
            .eraseToAnyPublisher()
        }
        .handleEvents(
            receiveOutput: { files in
                print("PlanService, attachMultipleFiles // Success : 다중 파일 첨부 완료 - \(files.count)개")
            },
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("PlanService, attachMultipleFiles // Exception : \(error.localizedDescription)")
                }
            }
        )
        .eraseToAnyPublisher()
    }
    
    /**
     * Plan의 파일 목록 조회
     * - 특정 Plan에 첨부된 모든 파일 조회
     * @param planUID: Plan UID
     * @return: 파일 목록 Publisher
     */
    func getAttachedFiles(planUID: String) -> AnyPublisher<[FileModel], Error> {
        print("PlanService, getAttachedFiles // Info : 첨부 파일 조회 - \(planUID)")
        
        return planRepository.readFiles(planUID: planUID)
            .handleEvents(
                receiveOutput: { files in
                    print("PlanService, getAttachedFiles // Success : 첨부 파일 조회 완료 - \(files.count)개")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("PlanService, getAttachedFiles // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    /**
     * 특정 파일 조회
     * - 파일 UID로 단일 파일 메타데이터 조회
     * @param fileUID: 파일 UID
     * @return: 파일 모델 Publisher
     */
    func getFile(fileUID: String) -> AnyPublisher<FileModel, Error> {
        print("PlanService, getFile // Info : 파일 조회 - \(fileUID)")
        
        return planRepository.readFile(fileUID: fileUID)
            .handleEvents(
                receiveOutput: { file in
                    print("PlanService, getFile // Success : 파일 조회 완료 - \(file.fileName)")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("PlanService, getFile // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    /**
     * 파일명 변경
     * - 파일의 표시명만 변경 (실제 파일시스템 파일은 그대로)
     * @param fileUID: 파일 UID
     * @param newFileName: 새로운 파일명
     * @return: 수정된 FileModel Publisher
     */
    func renameFile(fileUID: String, newFileName: String) -> AnyPublisher<FileModel, Error> {
        print("PlanService, renameFile // Info : 파일명 변경 - \(fileUID) → \(newFileName)")
        
        return Just(newFileName)
            .tryMap { [weak self] fileName in
                try self?.validateFileName(fileName).get()
                return fileName
            }
            .flatMap { [weak self] validatedFileName in
                guard let self = self else {
                    return Fail<FileModel, Error>(error: FileError.operationFailed)
                        .eraseToAnyPublisher()
                }
                return self.planRepository.updateFile(fileUID: fileUID, newFileName: validatedFileName)
            }
            .handleEvents(
                receiveOutput: { file in
                    print("PlanService, renameFile // Success : 파일명 변경 완료 - \(file.fileName)")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("PlanService, renameFile // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    /**
     * 파일 삭제
     * - Plan에서 파일 제거 및 파일시스템에서도 삭제
     * @param fileUID: 삭제할 파일 UID
     * @return: 삭제 완료 Publisher
     */
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
    
    // MARK: - ✅ Validation Logic (비즈니스 룰)
    
    /**
     * Plan 기본 검증
     */
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
    
    /**
     * 파일 데이터 검증
     */
    private func validateFileData(data: Data, fileName: String, fileType: String) -> Result<Void, FileError> {
        // 파일명 검증
        let fileNameValidation = validateFileName(fileName)
        guard case .success = fileNameValidation else {
            if case .failure(let error) = fileNameValidation {
                return .failure(error)
            }
            return .failure(.operationFailed)
        }
        
        // 파일 타입 검증
        let supportedTypes = ["jpg", "jpeg", "png", "gif", "pdf", "txt", "doc", "docx"]
        if !supportedTypes.contains(fileType.lowercased()) {
            print("PlanService, validateFileData // Warning : 지원하지 않는 파일 타입 - \(fileType)")
            return .failure(.unsupportedFileType)
        }
        
        // 빈 파일 체크
        if data.isEmpty {
            print("PlanService, validateFileData // Warning : 빈 파일")
            return .failure(.operationFailed)
        }
        
        return .success(())
    }
    
    /**
     * 파일명 검증
     */
    private func validateFileName(_ fileName: String) -> Result<Void, FileError> {
        let trimmedName = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName.isEmpty {
            print("PlanService, validateFileName // Warning : 빈 파일명")
            return .failure(.operationFailed)
        }
        
        // 금지된 문자 체크
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

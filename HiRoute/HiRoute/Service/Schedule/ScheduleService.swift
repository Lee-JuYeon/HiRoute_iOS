//
//  ScheduleService.swift
//  HiRoute
//
//  Created by Jupond on 12/2/25.
//
import Combine
import Foundation

class ScheduleService {
    
    // MARK: - Dependencies
    private let repository: ScheduleProtocol
    private let networkMonitor = NetworkMonitor()
    
    // MARK: - Reactive
    private var cancellables = Set<AnyCancellable>()
    
    /**
     * 초기화
     * @param repository: Schedule 데이터 액세스를 담당하는 Repository
     */
    init(repository: ScheduleProtocol) {
        self.repository = repository
        setupNetworkMonitoring()
        print("ScheduleService, init // Success : Repository 연결 완료")
    }
    
    private func setupNetworkMonitoring() {
        networkMonitor.startMonitoring { [weak self] networkStatus, connectionType in
            // 네트워크 상태 변화 처리
            print("ScheduleService, setupNetworkMonitoring // 네트워크 상태 변화 처리 : \(networkStatus), \(connectionType)")
                       
            if networkStatus == .connected {
                self?.processOfflineQueue()
            }
        }
    }
    
    private func processOfflineQueue() {
        QueueManager.shared.processQueue()
            .sink { [weak self] queueResults in
                guard let self = self else { return }

                print("ScheduleService, processOfflineQueue // Info : \(queueResults.count)개 오프라인 작업 서버 동기화 시작")
                            
                // 각 작업 타입별로 처리
                for queueResult in queueResults {
                    switch queueResult.operation {
                    case .create(let schedule):
                        self.processOfflineCreate(schedule)
                        
                    case .update(let schedule):
                        self.processOfflineUpdate(schedule)
                        
                    case .delete(let scheduleUID):
                        self.processOfflineDelete(scheduleUID)
                        
                    case .readAll:
                        self.processOfflineReadAll()
                        
                    case .read(let scheduleUID):
                        self.processOfflineRead(scheduleUID)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func processOfflineCreate(_ schedule: ScheduleModel) {
        print("ScheduleService, processOfflineCreate // Info : 오프라인 생성 작업 서버 동기화 - \(schedule.title)")
        // TODO: API 호출하여 서버에 생성
    }

    private func processOfflineUpdate(_ schedule: ScheduleModel) {
        print("ScheduleService, processOfflineUpdate // Info : 오프라인 수정 작업 서버 동기화 - \(schedule.title)")
        // TODO: API 호출하여 서버에 수정
    }

    private func processOfflineDelete(_ scheduleUID: String) {
        print("ScheduleService, processOfflineDelete // Info : 오프라인 삭제 작업 서버 동기화 - \(scheduleUID)")
        // TODO: API 호출하여 서버에서 삭제
    }

    private func processOfflineReadAll() {
        print("ScheduleService, processOfflineReadAll // Info : 서버 전체 목록 동기화")
        // TODO: API 호출하여 서버에서 전체 목록 가져오기
    }

    private func processOfflineRead(_ scheduleUID: String) {
        print("ScheduleService, processOfflineRead // Info : 서버 단일 일정 동기화 - \(scheduleUID)")
        // TODO: API 호출하여 서버에서 특정 일정 가져오기
    }
    
    
    /**
     * 새 일정 생성
     * - Schedule 고유 정보만 검증 후 저장
     * - VisitPlace 추가는 VisitPlaceService에서 별도 처리
     * @param schedule: 생성할 일정 모델
     * @return: 생성된 일정 Publisher
     */
    func create(_ schedule: ScheduleModel) -> AnyPublisher<ScheduleModel, Error> {
        print("ScheduleService, create // Info : 일정 생성 시작 - \(schedule.title)")
        
        return Just(schedule)
            .tryMap { [weak self] schedule in
                // Schedule 도메인 기본 검증만 수행
                try self?.validateSchedule(schedule).get()
                return schedule
            }
            .flatMap { [weak self] validatedSchedule in
                // 2. Repository 호출
                guard let self = self else {
                    return Fail<ScheduleModel, Error>(error: ScheduleError.unknown)
                        .eraseToAnyPublisher()
                }
                return self.repository.create(validatedSchedule)
            }
            .handleEvents(
                receiveOutput: { [weak self] createdSchedule in
                    print("ScheduleService, create // Success : 일정 생성 완료 - \(createdSchedule.title)")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("ScheduleService, create // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    /**
     * 특정 일정 조회
     * - UID로 단일 일정 조회
     * - Repository에서 직접 조회하여 최신 상태 반환
     * @param uid: 조회할 일정의 고유 식별자
     * @return: 조회된 일정 Publisher
     */
    func read(uid: String) -> AnyPublisher<ScheduleModel, Error> {
        print("ScheduleService, read // Info : 일정 조회 시작 - \(uid)")
        
        // 1. Repository에서 조회
        return repository.read(scheduleUID: uid)
            .handleEvents(
                receiveOutput: { [weak self] schedule in
                    print("ScheduleService, read // Success : 일정 조회 완료 - \(schedule.title)")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("ScheduleService, read // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    /**
     * 전체 일정 목록 조회 (페이지네이션)
     * - 사용자 친화적 정렬 적용: D-Day 가까운 순 → 최신 편집순
     * - 페이지네이션으로 메모리 효율성 확보
     * @param page: 페이지 번호 (0부터 시작)
     * @param itemsPerPage: 페이지당 항목 수
     * @return: 정렬된 일정 목록 Publisher
     */
    func readAll(page: Int = 0, itemsPerPage: Int = 10) -> AnyPublisher<[ScheduleModel], Error> {
        print("ScheduleService, readAll // Info : 전체 일정 조회 시작 - page:\(page)")
        
        return repository.readList(page: page, itemsPerPage: itemsPerPage)
            .map { [weak self] schedules in
                // 비즈니스 로직: 사용자 친화적 정렬
                return schedules.sorted { schedule1, schedule2 in
                    // 1순위: d_day가 가까운 순서
                    if schedule1.d_day == schedule2.d_day {
                        // 2순위: editDate 최신 순서
                        return schedule1.editDate > schedule2.editDate
                    }
                    return schedule1.d_day < schedule2.d_day
                }
            }
            .handleEvents(
                receiveOutput: { schedules in
                    print("ScheduleService, readAll // Success : 전체 조회 완료 - \(schedules.count)개")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("ScheduleService, readAll // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    /**
     * 기존 일정 수정
     * - Schedule 정보만 업데이트 (title, memo, d_day 등)
     * - VisitPlace 관련 수정은 VisitPlaceService에서 처리
     * @param schedule: 수정된 일정 모델
     * @return: 수정된 일정 Publisher
     */
    func update(_ schedule: ScheduleModel) -> AnyPublisher<ScheduleModel, Error> {
        print("ScheduleService, update // Info : 일정 업데이트 시작 - \(schedule.title)")
        
        return Just(schedule)
            .tryMap { [weak self] schedule in
                // 1. Schedule 도메인 검증
                try self?.validateSchedule(schedule).get()
                return schedule
            }
            .flatMap { [weak self] validatedSchedule in
                // 2. Repository 호출
                guard let self = self else {
                    return Fail<ScheduleModel, Error>(error: ScheduleError.unknown)
                        .eraseToAnyPublisher()
                }
                return self.repository.update(validatedSchedule)
            }
            .handleEvents(
                receiveOutput: { [weak self] updatedSchedule in
                    print("ScheduleService, update // Success : 일정 업데이트 완료 - \(updatedSchedule.title)")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("ScheduleService, update // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    /**
     * 일정 삭제
     * - Schedule과 관련된 모든 VisitPlace도 Cascade 삭제됨 (CoreData 설정)
     * - 물리적 파일 삭제는 FileService에서 별도 처리 필요
     * @param uid: 삭제할 일정의 고유 식별자
     * @return: 삭제 완료 Publisher
     */
    func delete(uid: String) -> AnyPublisher<Void, Error> {
        print("ScheduleService, delete // Info : 일정 삭제 시작 - \(uid)")
        
      
        
        // 내부에서 CompletionScope 판단하여 처리
        return determineDeleteStrategy(uid: uid)
            .flatMap { [weak self] completionScope -> AnyPublisher<Void, Error> in
                guard let self = self else {
                    return Fail(error: ScheduleError.unknown).eraseToAnyPublisher()
                }
                
                return self.handleDeleteResult(uid: uid, scope: completionScope)
            }
            .eraseToAnyPublisher()
    }
    
    private func determineDeleteStrategy(uid: String) -> AnyPublisher<CompletionScope, Never> {
        return Future<CompletionScope, Never> { [weak self] promise in
            guard let self = self else {
                promise(.success(.failure(ScheduleError.unknown)))
                return
            }
            
            if self.networkMonitor.isConnected {
                // 온라인 전략
                print("ScheduleService, determineDeleteStrategy // Info : 온라인 모드 감지")
                
                // TODO: 향후 API 구현시 .success로 변경
                // 현재: API 없으므로 localOnly 처리
                promise(.success(.localOnly))
                
            } else {
                // 오프라인 전략
                print("ScheduleService, determineDeleteStrategy // Info : 오프라인 모드 감지")
                
                do {
                    // CustomQueueManager에 서버 동기화 작업 등록
                    try QueueManager.shared.enqueueDelete(scheduleUID: uid)
                    promise(.success(.localOnly))
                    
                } catch {
                    promise(.success(.failure(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func handleDeleteResult(uid: String, scope: CompletionScope) -> AnyPublisher<Void, Error> {
        switch scope {
        case .success:
            print("ScheduleService, handleDeleteResult // Info : 전체 삭제 완료")
            return repository.delete(scheduleUID: uid)
            
        case .localOnly:
            print("ScheduleService, handleDeleteResult // Info : 로컬 삭제, 서버 동기화 예약됨")
            return repository.delete(scheduleUID: uid)
            
        case .failure(let error):
            print("ScheduleService, handleDeleteResult // Exception : \(error.localizedDescription)")
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    /**
     * 일정 기본 정보 업데이트
     * - 제목, 메모, D-Day만 수정하는 편의 메서드
     * - 기존 VisitPlace 목록은 그대로 유지
     * - editDate는 자동으로 현재 시간으로 업데이트
     * @param uid: 수정할 일정 UID
     * @param title: 새 제목
     * @param memo: 새 메모
     * @param dDay: 새 D-Day
     * @return: 수정된 일정 Publisher
     */
    func updateScheduleInfo(uid: String, title: String, memo: String, dDay: Date) -> AnyPublisher<ScheduleModel, Error> {
        print("ScheduleService, updateScheduleInfo // Info : 일정 정보 업데이트 - \(uid)")
        
        return read(uid: uid)
            .map { schedule in
                // Immutable 패턴으로 새 Schedule 생성
                return ScheduleModel(
                    uid: schedule.uid,
                    index: schedule.index,
                    title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                    memo: memo,
                    editDate: Date(), // 편집 날짜 자동 갱신
                    d_day: dDay,
                    planList: schedule.planList // 기존 방문장소 유지
                )
            }
            .flatMap { [weak self] updatedSchedule in
                guard let self = self else {
                    return Fail<ScheduleModel, Error>(error: ScheduleError.unknown)
                        .eraseToAnyPublisher()
                }
                return self.update(updatedSchedule)
            }
            .eraseToAnyPublisher()
    }
    
    /**
     * Schedule 기본 검증
     * - 사용자 편의성 우선으로 최소한의 검증만 수행
     * - 제목 길이 제한 없음, 내용 제한 없음
     * - UID 존재 여부만 확인
     * @param schedule: 검증할 일정 모델
     * @return: 검증 결과
     */
    private func validateSchedule(_ schedule: ScheduleModel) -> Result<Void, ScheduleError> {
        // 최소한의 검증만: 필수 필드 존재 여부
        if schedule.uid.isEmpty {
            print("ScheduleService, validateBasicSchedule // Warning : UID가 비어있음")
            return .failure(.saveFailed)
        }
        
        // 사용자 편의성을 위해 다른 제한 없음:
        // - 제목 길이 제한 없음 (긴 제목도 허용)
        // - 빈 제목도 허용 (나중에 수정 가능)
        // - 과거 D-Day도 허용 (추억 여행 등)
        
        return .success(())
    }
    
    deinit {
        networkMonitor.stopMonitoring()
        cancellables.removeAll()
        print("ScheduleService, deinit // Success : 서비스 해제 완료")
    }
}

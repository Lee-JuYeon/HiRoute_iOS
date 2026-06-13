//
//  ScheduleService.swift
//  HiRoute
//
//  Created by Jupond on 12/2/25.
//
import Combine
import Foundation
import CoreData

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
                self?.performSync()
            }
        }
    }

    // MARK: - 서버 동기화

    /// 앱 시작 / 네트워크 복구 시 호출. CoreData 로드 후 백그라운드에서 실행.
    ///
    /// 흐름:
    /// 1. QueueManager 미동기화 항목 수집 (오프라인 중 create/update/delete)
    /// 2. POST /api/schedules/sync { last_sync_at, changes }
    /// 3. server_changes → CoreData upsert
    /// 4. deleted_on_server → CoreData delete
    /// 5. last_sync_at UserDefaults 갱신
    func syncWithServer() -> AnyPublisher<Void, Never> {
        guard networkMonitor.isConnected else {
            print("ScheduleService, syncWithServer // Info : 오프라인 - 동기화 건너뜀")
            return Just(()).eraseToAnyPublisher()
        }

        let lastSyncAt = UserDefaults.standard.string(forKey: "schedule_last_sync_at") ?? "1970-01-01T00:00:00Z"

        return QueueManager.shared.processQueue()
            .flatMap { [weak self] queueResults -> AnyPublisher<Void, Never> in
                guard let self = self else { return Just(()).eraseToAnyPublisher() }

                var created: [ScheduleCreateRequest] = []
                var updated: [ScheduleSyncUpdateItem] = []
                var deleted: [String] = []

                for result in queueResults {
                    switch result.operation {
                    case .create(let schedule): created.append(schedule.toCreateRequest())
                    case .update(let schedule): updated.append(schedule.toSyncUpdateItem())
                    case .delete(let uid):      deleted.append(uid)
                    default: break
                    }
                }

                let request = ScheduleSyncRequest(
                    lastSyncAt: lastSyncAt,
                    changes: ScheduleSyncChanges(created: created, updated: updated, deleted: deleted)
                )

                print("ScheduleService, syncWithServer // Info : 동기화 시작 (create:\(created.count), update:\(updated.count), delete:\(deleted.count))")

                let publisher: AnyPublisher<APIResponse<ScheduleSyncResponse>, Error> =
                    APIClient.shared.postWithAuth(path: "/api/schedules/sync", body: request)

                return publisher
                    .flatMap { [weak self] response -> AnyPublisher<Void, Error> in
                        guard let self = self else {
                            return Fail(error: ScheduleError.unknown).eraseToAnyPublisher()
                        }
                        return self.applyServerSync(response.data)
                    }
                    .handleEvents(receiveOutput: {
                        print("ScheduleService, syncWithServer // Success : 서버 동기화 완료")
                    })
                    .catch { error -> Just<Void> in
                        print("ScheduleService, syncWithServer // Warning : 동기화 실패 - \(error.localizedDescription)")
                        return Just(())
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func applyServerSync(_ sync: ScheduleSyncResponse) -> AnyPublisher<Void, Error> {
        UserDefaults.standard.set(sync.syncAt, forKey: "schedule_last_sync_at")

        let upserts: [AnyPublisher<Void, Error>] = sync.serverChanges.map { $0.toModel() }.map { [weak self] schedule in
            guard let self = self else {
                return Fail(error: ScheduleError.unknown).eraseToAnyPublisher()
            }
            return self.repository.update(schedule)
                .catch { [weak self] error -> AnyPublisher<ScheduleModel, Error> in
                    guard let self = self else {
                        return Fail(error: ScheduleError.unknown).eraseToAnyPublisher()
                    }
                    // 서버에는 있지만 로컬에 없으면 create
                    if let se = error as? ScheduleError, case .notFound = se {
                        return self.repository.create(schedule)
                    }
                    return Just(schedule).setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                .map { _ in () }
                .eraseToAnyPublisher()
        }

        let deletes: [AnyPublisher<Void, Error>] = sync.deletedOnServer.map { [weak self] uid in
            guard let self = self else {
                return Fail(error: ScheduleError.unknown).eraseToAnyPublisher()
            }
            return self.repository.delete(scheduleUID: uid)
                .catch { _ in Just(()).setFailureType(to: Error.self).eraseToAnyPublisher() }
                .eraseToAnyPublisher()
        }

        let all = upserts + deletes
        guard !all.isEmpty else {
            print("ScheduleService, applyServerSync // Info : 서버 변경사항 없음")
            return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        print("ScheduleService, applyServerSync // Info : upsert \(upserts.count)개, delete \(deletes.count)개")
        return Publishers.MergeMany(all)
            .collect()
            .map { _ in () }
            .eraseToAnyPublisher()
    }

    private func performSync() {
        syncWithServer()
            .sink { _ in }
            .store(in: &cancellables)
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
        let request = schedule.toCreateRequest()
        let publisher: AnyPublisher<APIResponse<ScheduleResponse>, Error> =
            APIClient.shared.postWithAuth(path: "/api/schedules", body: request)
        publisher
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("ScheduleService, processOfflineCreate // Exception : 서버 동기화 실패 - \(error.localizedDescription)")
                        // 실패 시 다시 큐에 등록
                        try? QueueManager.shared.enqueueCreate(schedule: schedule)
                    }
                },
                receiveValue: { response in
                    print("ScheduleService, processOfflineCreate // Success : 서버 동기화 완료 - \(response.data.title)")
                }
            )
            .store(in: &cancellables)
    }

    private func processOfflineUpdate(_ schedule: ScheduleModel) {
        print("ScheduleService, processOfflineUpdate // Info : 오프라인 수정 작업 서버 동기화 - \(schedule.title)")
        let request = schedule.toUpdateRequest()
        let publisher: AnyPublisher<APIResponse<ScheduleResponse>, Error> =
            APIClient.shared.putWithAuth(path: "/api/schedules/\(schedule.uid)", body: request)
        publisher
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("ScheduleService, processOfflineUpdate // Exception : 서버 동기화 실패 - \(error.localizedDescription)")
                        try? QueueManager.shared.enqueueUpdate(schedule: schedule)
                    }
                },
                receiveValue: { response in
                    print("ScheduleService, processOfflineUpdate // Success : 서버 동기화 완료 - \(response.data.title)")
                }
            )
            .store(in: &cancellables)
    }

    private func processOfflineDelete(_ scheduleUID: String) {
        print("ScheduleService, processOfflineDelete // Info : 오프라인 삭제 작업 서버 동기화 - \(scheduleUID)")
        let publisher: AnyPublisher<APIResponse<ScheduleResponse>, Error> =
            APIClient.shared.deleteWithAuth(path: "/api/schedules/\(scheduleUID)")
        publisher
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("ScheduleService, processOfflineDelete // Exception : 서버 동기화 실패 - \(error.localizedDescription)")
                        try? QueueManager.shared.enqueueDelete(scheduleUID: scheduleUID)
                    }
                },
                receiveValue: { response in
                    print("ScheduleService, processOfflineDelete // Success : 서버 삭제 동기화 완료 - \(scheduleUID)")
                }
            )
            .store(in: &cancellables)
    }

    private func processOfflineReadAll() {
        print("ScheduleService, processOfflineReadAll // Info : 서버 전체 목록 동기화")
        let queryItems = [
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "limit", value: "100")
        ]
        let publisher: AnyPublisher<APIResponse<[ScheduleResponse]>, Error> =
            APIClient.shared.getWithAuth(path: "/api/schedules", queryItems: queryItems)
        publisher
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("ScheduleService, processOfflineReadAll // Exception : 서버 동기화 실패 - \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] response in
                    guard let self = self else { return }
                    let serverSchedules = response.data.map { $0.toModel() }
                    print("ScheduleService, processOfflineReadAll // Success : 서버에서 \(serverSchedules.count)개 일정 수신")
                    // 서버 데이터를 로컬에 병합 (서버 데이터를 로컬에 upsert)
                    for schedule in serverSchedules {
                        self.repository.update(schedule)
                            .sink(
                                receiveCompletion: { _ in },
                                receiveValue: { _ in }
                            )
                            .store(in: &self.cancellables)
                    }
                }
            )
            .store(in: &cancellables)
    }

    private func processOfflineRead(_ scheduleUID: String) {
        print("ScheduleService, processOfflineRead // Info : 서버 단일 일정 동기화 - \(scheduleUID)")
        let publisher: AnyPublisher<APIResponse<ScheduleResponse>, Error> =
            APIClient.shared.getWithAuth(path: "/api/schedules/\(scheduleUID)")
        publisher
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("ScheduleService, processOfflineRead // Exception : 서버 동기화 실패 - \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] response in
                    guard let self = self else { return }
                    let serverSchedule = response.data.toModel()
                    print("ScheduleService, processOfflineRead // Success : 서버에서 일정 수신 - \(serverSchedule.title)")
                    // 서버 데이터를 로컬에 병합
                    self.repository.update(serverSchedule)
                        .sink(
                            receiveCompletion: { _ in },
                            receiveValue: { _ in }
                        )
                        .store(in: &self.cancellables)
                }
            )
            .store(in: &cancellables)
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
            // Schedule 도메인 검증 수행
            .tryMap { [weak self] schedule in
                // uid 검증 등
                try self?.validateSchedule(schedule).get()
                return schedule
            }
            // repository 호출
            .flatMap { [weak self] validatedSchedule in
                guard let self = self else {
                    return Fail<ScheduleModel, Error>(error: ScheduleError.unknown)
                        .eraseToAnyPublisher()
                }
                return self.repository.create(validatedSchedule) // repository 위임
            }
            // 로깅 + 서버 동기화
            .handleEvents(
                receiveOutput: { [weak self] createdSchedule in
                    guard let self = self else { return }
                    print("ScheduleService, create // Success : 일정 생성 완료 - \(createdSchedule.title)")

                    // 서버 동기화 (fire-and-forget)
                    if self.networkMonitor.isConnected {
                        let request = createdSchedule.toCreateRequest()
                        let publisher: AnyPublisher<APIResponse<ScheduleResponse>, Error> =
                            APIClient.shared.postWithAuth(path: "/api/schedules", body: request)
                        publisher
                            .sink(
                                receiveCompletion: { completion in
                                    if case .failure(let error) = completion {
                                        print("ScheduleService, create // Warning : 서버 동기화 실패, 큐 등록 - \(error.localizedDescription)")
                                        try? QueueManager.shared.enqueueCreate(schedule: createdSchedule)
                                    }
                                },
                                receiveValue: { response in
                                    print("ScheduleService, create // Success : 서버 동기화 완료 - \(response.data.title)")
                                }
                            )
                            .store(in: &self.cancellables)
                    } else {
                        // 오프라인: 큐에 등록
                        try? QueueManager.shared.enqueueCreate(schedule: createdSchedule)
                        print("ScheduleService, create // Info : 오프라인 - 큐 등록 완료")
                    }
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
        
        return repository.readAll(page: page, itemsPerPage: itemsPerPage)
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
                    guard let self = self else { return }
                    print("ScheduleService, update // Success : 일정 업데이트 완료 - \(updatedSchedule.title)")

                    // 서버 동기화 (fire-and-forget) — PUT 실패(404) 시 POST로 폴백
                    if self.networkMonitor.isConnected {
                        let updateRequest = updatedSchedule.toUpdateRequest()
                        let publisher: AnyPublisher<APIResponse<ScheduleResponse>, Error> =
                            APIClient.shared.putWithAuth(path: "/api/schedules/\(updatedSchedule.uid)", body: updateRequest)
                        publisher
                            .sink(
                                receiveCompletion: { [weak self] completion in
                                    if case .failure(let error) = completion {
                                        // 404 = 서버에 없음 → CREATE로 폴백
                                        if let networkError = error as? NetworkError,
                                           case .serverError(404) = networkError {
                                            print("ScheduleService, update // Info : 서버에 없음(404), CREATE로 폴백 - \(updatedSchedule.title)")
                                            self?.syncCreateToServer(updatedSchedule)
                                        } else {
                                            print("ScheduleService, update // Warning : 서버 동기화 실패, 큐 등록 - \(error.localizedDescription)")
                                            try? QueueManager.shared.enqueueUpdate(schedule: updatedSchedule)
                                        }
                                    }
                                },
                                receiveValue: { response in
                                    print("ScheduleService, update // Success : 서버 동기화 완료 - \(response.data.title)")
                                }
                            )
                            .store(in: &self.cancellables)
                    } else {
                        try? QueueManager.shared.enqueueUpdate(schedule: updatedSchedule)
                        print("ScheduleService, update // Info : 오프라인 - 큐 등록 완료")
                    }
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
        if networkMonitor.isConnected {
            // 온라인: 서버 DELETE 호출 후 결과에 따라 CompletionScope 결정
            print("ScheduleService, determineDeleteStrategy // Info : 온라인 모드 감지")
            let publisher: AnyPublisher<APIResponse<ScheduleResponse>, Error> =
                APIClient.shared.deleteWithAuth(path: "/api/schedules/\(uid)")
            return publisher
                .map { response -> CompletionScope in
                    print("ScheduleService, determineDeleteStrategy // Success : 서버 삭제 완료 - \(uid)")
                    return .success
                }
                .catch { error -> Just<CompletionScope> in
                    print("ScheduleService, determineDeleteStrategy // Warning : 서버 삭제 실패, 로컬만 삭제 - \(error.localizedDescription)")
                    // 서버 실패해도 로컬은 삭제하되 큐에 등록
                    try? QueueManager.shared.enqueueDelete(scheduleUID: uid)
                    return Just(.localOnly)
                }
                .eraseToAnyPublisher()
        } else {
            // 오프라인: 큐에 등록 후 로컬만 삭제
            print("ScheduleService, determineDeleteStrategy // Info : 오프라인 모드 감지")
            do {
                try QueueManager.shared.enqueueDelete(scheduleUID: uid)
                return Just(.localOnly).eraseToAnyPublisher()
            } catch {
                return Just(.failure(error)).eraseToAnyPublisher()
            }
        }
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
    /// [2026-05-26 Phase 2 리팩터] 풀 update 경로 제거.
    /// 이전엔 read → 새 ScheduleModel 생성 → full update() 였는데, 새 모델 생성 시 chatHistory
    /// 누락하면 DAO가 replace-all로 채팅 wipe하던 치명 버그. 이제 메타 업데이트 전용 메서드
    /// updateMeta()로 directly 호출 → 애초에 chatHistory를 거치지 않음.
    func updateScheduleInfo(uid: String, title: String, memo: String, dDay: Date) -> AnyPublisher<ScheduleModel, Error> {
        print("ScheduleService, updateScheduleInfo // Info : 일정 정보 업데이트 - \(uid)")
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return repository.updateMeta(scheduleUID: uid, title: trimmedTitle, memo: memo, dDay: dDay, editDate: Date())
            .handleEvents(receiveOutput: { updated in
                print("ScheduleService, updateScheduleInfo // Success : 메타 업데이트 완료 - \(updated.title)")
            })
            .eraseToAnyPublisher()
    }
    
    /**
     * 일정 순서 재정렬
     * - scheduleUIDs: 새로운 순서대로 정렬된 Schedule UID 배열
     * - 각 Schedule의 index가 배열 순서에 맞게 업데이트됨
     */
    func reorderSchedules(scheduleUIDs: [String]) -> AnyPublisher<[ScheduleModel], Error> {
        print("ScheduleService, reorderSchedules // Info : Schedule 순서 재정렬 - \(scheduleUIDs.count)개")

        return repository.reorderSchedules(scheduleUIDs: scheduleUIDs)
            .handleEvents(
                receiveOutput: { [weak self] schedules in
                    guard let self = self else { return }
                    print("ScheduleService, reorderSchedules // Success : Schedule 순서 재정렬 완료 - \(schedules.count)개")

                    // 서버 동기화 (fire-and-forget)
                    let orders = scheduleUIDs.enumerated().map { index, uid in
                        ReorderItem(uid: uid, indexOrder: index)
                    }
                    let request = ScheduleReorderRequest(orders: orders)

                    if self.networkMonitor.isConnected {
                        let publisher: AnyPublisher<APIResponse<[ScheduleResponse]>, Error> =
                            APIClient.shared.putWithAuth(path: "/api/schedules/reorder", body: request)
                        publisher
                            .sink(
                                receiveCompletion: { completion in
                                    if case .failure(let error) = completion {
                                        print("ScheduleService, reorderSchedules // Warning : 서버 동기화 실패 - \(error.localizedDescription)")
                                    }
                                },
                                receiveValue: { response in
                                    print("ScheduleService, reorderSchedules // Success : 서버 순서 동기화 완료")
                                }
                            )
                            .store(in: &self.cancellables)
                    } else {
                        print("ScheduleService, reorderSchedules // Info : 오프라인 - 순서 변경은 다음 동기화 시 반영")
                    }
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("ScheduleService, reorderSchedules // Exception : \(error.localizedDescription)")
                    }
                }
            )
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
    /// 서버에 CREATE 요청 (update 404 폴백용)
    private func syncCreateToServer(_ schedule: ScheduleModel) {
        let createRequest = schedule.toCreateRequest()
        let publisher: AnyPublisher<APIResponse<ScheduleResponse>, Error> =
            APIClient.shared.postWithAuth(path: "/api/schedules", body: createRequest)
        publisher
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("ScheduleService, syncCreateToServer // Warning : CREATE 폴백도 실패, 큐 등록 - \(error.localizedDescription)")
                        try? QueueManager.shared.enqueueCreate(schedule: schedule)
                    }
                },
                receiveValue: { response in
                    print("ScheduleService, syncCreateToServer // Success : 서버에 생성 완료 - \(response.data.title)")
                }
            )
            .store(in: &cancellables)
    }


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
    
    /// 일정에 채팅 메시지 한 건만 추가 (전체 update보다 가벼움)
    func appendChatMessage(scheduleUID: String, message: ChatMessageModel) -> AnyPublisher<Void, Error> {
        return repository.appendChatMessage(scheduleUID: scheduleUID, message: message)
            .eraseToAnyPublisher()
    }

    deinit {
        networkMonitor.stopMonitoring()
        cancellables.removeAll()
        print("ScheduleService, deinit // Success : 서비스 해제 완료")
    }
}

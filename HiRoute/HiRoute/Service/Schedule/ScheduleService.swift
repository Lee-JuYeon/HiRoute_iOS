//
//  ScheduleService.swift
//  HiRoute
//
//  Created by Jupond on 12/2/25.
//
import Combine
import Foundation

/*
 MVVM + Service Layer에서의 Service의 역할
 - 중복 체크 & 최대 개수 검증
 - 상태 관리 (@Published)
 - UI용 Publisher 제공
 - 복합 연산 (검색, 필터링)
 */

/*
 1. respository가 지금 굳이 필요하나? 통합해야하나?
     도메인 복잡성: Schedule + Place 조합 로직
     확장성: 결제, 알림, 추천 기능 추가 시
     테스트 용이성: Mock Repository 주입 가능
     책임 분리: Repository(데이터) vs Service(비즈니스)
 2. cache파일 매니저 필요하나?
     통합 메모리 관리: 전체 앱 캐시를 한곳에서
     일관된 정책: TTL, LRU 등 통일된 정책
     타입 안전성: Generic으로 타입 보장
     성능 모니터링: 캐시 히트율 추적 가능
 3. offline queue 관련 파일매니저를 다로 구현해야하나? (로컬 디비?)
 */

class ScheduleService {
    
    private let repository: ScheduleProtocol
    private let networkMonitor: NetworkMonitor
    private let cacheManager: CacheManager
    private let queueManager: QueueManager
    
    private let queueName = "schedule_sync"
    private var cancellables = Set<AnyCancellable>()
    
    init(
        scheduleRepository: ScheduleProtocol,
        networkMonitor: NetworkMonitor,
        cacheManager: CacheManager = .shared,
        queueManager: QueueManager = .shared
    ) {
        self.repository = scheduleRepository
        self.networkMonitor = networkMonitor
        self.cacheManager = cacheManager
        self.queueManager = queueManager
        
        setupQueue()
        setupNetworkStatusObserver()
    }
    
    // 오프라인 작업 큐
    private var offlineQueue: [OfflineOperation] = []
       
    
    // 리액티브 상태 스트림
    @Published private var currentSchedule: ScheduleModel?
    @Published private var scheduleList: [ScheduleModel] = []
    @Published private var isLoading = false
    @Published private var errorMessage: String?
    
    // 공개 스트림 - UI가 구독하는 Publisher들
    var schedulePublisher: AnyPublisher<ScheduleModel?, Never> {
        $currentSchedule.eraseToAnyPublisher()
    }
    
    var scheduleListPublisher: AnyPublisher<[ScheduleModel], Never> {
        $scheduleList.eraseToAnyPublisher()
    }
    
    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        $isLoading.eraseToAnyPublisher()
    }
    
    var errorPublisher: AnyPublisher<String?, Never> {
        $errorMessage.eraseToAnyPublisher()
    }
        
   
    
    // 네트워크 상태 변화 감지
    private func setupNetworkStatusObserver() {
        networkMonitor.startMonitoring { [weak self] networkStatus, connectionType in
            // 온라인 상태가 되면 오프라인 큐 처리
            if networkStatus == .connected {
                self?.processOfflineQueue()
            }
        }
    }
       
    // 온라인 상태가 되면 오프라인 큐 처리
    private func processOfflineQueue() {
        guard !offlineQueue.isEmpty else { return }
        
        print("🔄 오프라인 큐 처리 시작: \(offlineQueue.count)개 작업")
        
        let operations = offlineQueue
        offlineQueue.removeAll()
        
        for operation in operations {
            switch operation {
            case .create(let schedule):
                syncCreateToServer(schedule)
                    .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
                    .store(in: &cancellables)
                
            case .update(let schedule):
                syncUpdateToServer(schedule)
                    .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
                    .store(in: &cancellables)
                
            case .delete(let uid):
                syncDeleteToServer(uid: uid)
                    .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
                    .store(in: &cancellables)
            }
        }
    }
    
    // 새로운 스케줄을 생성하고 현재 스케줄과 리스트에 자동 반영,  오프라인 우선 처리
    
    // 모델 생성 서버 동기화
    private func syncCreateToServer(_ schedule: ScheduleModel) -> AnyPublisher<ScheduleModel, Error> {
        return repository.createSchedule(schedule)
            .handleEvents(
                receiveOutput: { [weak self] _ in
//                        self?.currentSchedule = createdSchedule  // 현재 스케줄로 설정
//                        self?.addToScheduleList(createdSchedule) // 리스트에 추가
                    self?.isLoading = false
                },
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    
    /// 스케줄 리스트에 새 스케줄 추가 (중복 체크)
    private func addToScheduleList(_ schedule: ScheduleModel) {
        if !scheduleList.contains(where: { $0.uid == schedule.uid }) {
            scheduleList.append(schedule)
        }
    }
      
    
    func create(_ schedule: ScheduleModel) -> AnyPublisher<ScheduleModel, Error> {
        // 1. 중복체크
        if scheduleList.contains(where: { $0.uid == schedule.uid }) {
            return Fail(error: ScheduleError.duplicateSchedule)
                .eraseToAnyPublisher()
        }
        
        // 2. 로컬DB에 먼저 저장 (오프라인 우선)
        saveToLocalDB(schedule)
        
        
        // 3. 메모리에 추가 (중복체크 후)
        isLoading = true
        errorMessage = nil
        
        scheduleList.append(schedule)
        currentSchedule = schedule
               
        // 2. 네트워크 상태 확인 후 처리
        let (networkStatus, _) = networkMonitor.getCurrentStatus()
               
        switch networkStatus {
        case .connected:
            // 온라인: 즉시 서버 동기화
            return syncCreateToServer(schedule)
        case .offline, .connecting:
            // 오프라인: 큐에 추가 후 로컬 완료 처리
            offlineQueue.append(OfflineOperation.create(schedule))
            isLoading = false
            return Just(schedule)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    // 모델 업데이트 서버 동기화
    private func syncUpdateToServer(_ schedule: ScheduleModel) -> AnyPublisher<ScheduleModel, Error> {
        return repository.updateSchedule(schedule)
            .handleEvents(
                receiveOutput: { [weak self] _ in
//                    self?.currentSchedule = updatedSchedule     // 현재 스케줄 업데이트
//                    self?.updateInScheduleList(updatedSchedule) // 리스트에서도 업데이트
                    self?.isLoading = false
                },
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                }
            )
            .eraseToAnyPublisher()
    }
        
    /// 오프라인 작업을 큐에 추가
    private func addToOfflineQueue(_ operation: OfflineOperation) {
        offlineQueue.append(operation)
        print("📱 오프라인 작업 큐에 추가: \(operation)")
    }
    
    /// 로컬 스케줄 업데이트
    private func updateLocalSchedule(_ schedule: ScheduleModel) {
        if let index = scheduleList.firstIndex(where: { $0.uid == schedule.uid }) {
            scheduleList[index] = schedule
        }
        
        if currentSchedule?.uid == schedule.uid {
            currentSchedule = schedule
        }
    }
    
    
    /// 현재 스케줄의 메모를 업데이트
    func updateMemo(_ memo: String) -> AnyPublisher<ScheduleModel, Error> {
        guard let schedule = currentSchedule else {
            let error = ScheduleError.noCurrentSchedule
            errorMessage = error.localizedDescription
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        let updatedSchedule = schedule.updateModel(ScheduleModel(
            uid: schedule.uid,
            index: schedule.index,
            title: schedule.title,
            memo: memo,  // 메모만 변경
            editDate: Date(),
            d_day: schedule.d_day,
            visitPlaceList: schedule.visitPlaceList
        ))
        
        return update(updatedSchedule)
    }
        
    /// 캐시 업데이트 (Repository에 위임)
    private func updateCache(_ schedule: ScheduleModel) {
        // Repository의 캐시 업데이트 로직 활용
        repository.updateSchedule(schedule)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
       
       
    // 스케줄을 업데이트하고 현재 스케줄과 리스트에 자동 반영
    func update(_ schedule: ScheduleModel) -> AnyPublisher<ScheduleModel, Error> {
        isLoading = true
        errorMessage = nil
        
        // 1. 로컬 즉시 반영
        updateLocalSchedule(schedule)
        
        // 2. 캐시 업데이트
        updateCache(schedule)
        
        // 3. 네트워크 상태 확인 후 서버 동기화
        let (networkStatus, _) = networkMonitor.getCurrentStatus()
        
        switch networkStatus {
        case .connected:
            return syncUpdateToServer(schedule)
        case .offline, .connecting:
            addToOfflineQueue(.update(schedule))
            isLoading = false
            return Just(schedule)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    
    /// 캐시 엔트리 제거
    private func removeCacheEntry(uid: String) {
        // Repository의 삭제 로직으로 캐시도 정리됨
    }
    
    // 특정 UID로 스케줄을 로드하고 현재 스케줄로 설정
    func read(uid: String) -> AnyPublisher<ScheduleModel, Error> {
        isLoading = true
        errorMessage = nil
        
        // 1. 로컬에서 먼저 확인
        if let localSchedule = scheduleList.first(where: { $0.uid == uid }) {
            currentSchedule = localSchedule
            isLoading = false
            return Just(localSchedule)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        // 2. Repository (캐시 + 서버) 통해 로드
        return repository.readSchedule(scheduleModelUID: uid)
            .handleEvents(
                receiveOutput: { [weak self] schedule in
                    self?.currentSchedule = schedule  // 현재 스케줄로 설정
                    
                    // 로컬 리스트에 추가 (중복 방지)
                    if let strongSelf = self,
                       !strongSelf.scheduleList.contains(where: { $0.uid == schedule.uid }) {
                        strongSelf.scheduleList.append(schedule)
                    }
                    
                    self?.isLoading = false
                },
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    // 스케줄 목록을 페이징으로 로드 (page=0이면 새로고침, 그외는 추가로드)
    func readList(page: Int = 0, itemsPerPage: Int = 8) -> AnyPublisher<[ScheduleModel], Error> {
        isLoading = true
        errorMessage = nil
        
        return repository.readScheduleList(page: page, itemsPerPage: itemsPerPage)
            .handleEvents(
                receiveOutput: { [weak self] schedules in
                    if page == 0 {
                        self?.scheduleList = schedules        // 새로고침
                    } else {
                        self?.scheduleList.append(contentsOf: schedules) // 추가로드
                    }
                    self?.isLoading = false
                },
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    /// 스케줄 리스트에서 특정 UID의 스케줄 제거
    private func removeFromScheduleList(uid: String) {
        scheduleList.removeAll { $0.uid == uid }
    }
    
    // 모델 삭제 서버 동기화
    private func syncDeleteToServer(uid: String) -> AnyPublisher<Void, Error> {
        return repository.deleteSchedule(scheduleModelUID: uid)
            .handleEvents(
                receiveOutput: { [weak self] _ in
//                    self?.removeFromScheduleList(uid: uid)  // 리스트에서 제거
//                    if self?.currentSchedule?.uid == uid {
//                        self?.currentSchedule = nil         // 현재 스케줄이면 nil로 설정
//                    }
                    self?.isLoading = false
                },
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                }
            )
            .eraseToAnyPublisher()
    }
   
    // 스케줄을 삭제하고 현재 스케줄과 리스트에서 자동 제거
    func delete(uid: String) -> AnyPublisher<Void, Error> {
        isLoading = true
        errorMessage = nil
        
        // 1. 로컬에서 즉시 삭제
        scheduleList.removeAll { $0.uid == uid }
        if currentSchedule?.uid == uid {
            currentSchedule = nil
        }
        
        // 2. 캐시에서 제거
        removeCacheEntry(uid: uid)
        
        // 3. 네트워크 상태 확인 후 서버 동기화
        let (networkStatus, _) = networkMonitor.getCurrentStatus()
        switch networkStatus {
        case .connected:
            return syncDeleteToServer(uid: uid)
        case .offline, .connecting:
            addToOfflineQueue(.delete(uid))
            isLoading = false
            return Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    // MARK: - 비즈니스 로직 (리액티브)
    /// 현재 스케줄에 장소를 추가 (중복체크, 최대개수 검증 포함)
    func addPlace(_ place: PlaceModel) -> AnyPublisher<ScheduleModel, Error> {
        guard let schedule = currentSchedule else {
            let error = ScheduleError.noCurrentSchedule
            errorMessage = error.localizedDescription
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return Just(schedule)
            .tryMap { [weak self] schedule in
                try self?.addPlaceLocally(place, to: schedule) ?? schedule
            }
            .flatMap { [weak self] updatedSchedule in
                self?.update(updatedSchedule) ??
                Fail(error: ScheduleError.updateFailed).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    /// 로컬에서 장소 추가 로직 (비즈니스 규칙 검증)
    private func addPlaceLocally(_ place: PlaceModel, to schedule: ScheduleModel) throws -> ScheduleModel {
        // 최대 20개 제한
        guard schedule.visitPlaceList.count < 20 else {
            throw ScheduleError.maxPlacesReached
        }
        
        // 중복 장소 체크
        guard !schedule.visitPlaceList.contains(where: { $0.placeModel.uid == place.uid }) else {
            throw ScheduleError.duplicatePlace
        }
        
        let newVisitPlace = VisitPlaceModel(
            uid: UUID().uuidString,
            index: schedule.visitPlaceList.count,
            memo: "",
            placeModel: place,
            files: []
        )
        
        var updatedVisitPlaces = schedule.visitPlaceList
        updatedVisitPlaces.append(newVisitPlace)
        
        return schedule.updateModel(ScheduleModel(
            uid: schedule.uid,
            index: schedule.index,
            title: schedule.title,
            memo: schedule.memo,
            editDate: Date(),
            d_day: schedule.d_day,
            visitPlaceList: updatedVisitPlaces
        ))
    }
    
    /// 현재 스케줄에서 특정 인덱스의 장소를 제거
    func removePlace(at index: Int) -> AnyPublisher<ScheduleModel, Error> {
        guard let schedule = currentSchedule else {
            let error = ScheduleError.noCurrentSchedule
            errorMessage = error.localizedDescription
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        return Just(schedule)
            .map { schedule in
                var updated = schedule
                if index < updated.visitPlaceList.count {
                    var newVisitPlaces = updated.visitPlaceList
                    newVisitPlaces.remove(at: index)  // 해당 인덱스 장소 제거
                    updated = updated.updateModel(ScheduleModel(
                        uid: updated.uid,
                        index: updated.index,
                        title: updated.title,
                        memo: updated.memo,
                        editDate: Date(),
                        d_day: updated.d_day,
                        visitPlaceList: newVisitPlaces
                    ))
                }
                return updated
            }
            .flatMap { [weak self] updatedSchedule in
                self?.update(updatedSchedule) ??
                Fail(error: ScheduleError.updateFailed).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
   

    /// 스케줄 리스트에서 기존 스케줄을 업데이트된 버전으로 교체
    private func updateInScheduleList(_ schedule: ScheduleModel) {
        if let index = scheduleList.firstIndex(where: { $0.uid == schedule.uid }) {
            scheduleList[index] = schedule
        }
    }
    
  
    /// 제목으로 스케줄을 실시간 검색 (대소문자 무시)
    func searchSchedules(by title: String) -> AnyPublisher<[ScheduleModel], Never> {
        $scheduleList
            .map { schedules in
                schedules.filter { $0.title.lowercased().contains(title.lowercased()) }
            }
            .eraseToAnyPublisher()
    }
    
    /// 다가오는 스케줄만 필터링해서 날짜순 정렬
    func getUpcomingSchedules() -> AnyPublisher<[ScheduleModel], Never> {
        $scheduleList
            .map { schedules in
                schedules.filter { $0.d_day > Date() }
                    .sorted { $0.d_day < $1.d_day }
            }
            .eraseToAnyPublisher()
    }
}
    
   

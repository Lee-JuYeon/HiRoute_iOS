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

class ScheduleService {
    private let repository: ScheduleProtocol
    
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
    
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: ScheduleProtocol) {
        self.repository = repository
    }
    
    // MARK: - 리액티브 CRUD Operations
    
    /// 새로운 스케줄을 생성하고 현재 스케줄과 리스트에 자동 반영
    func create(_ schedule: ScheduleModel) -> AnyPublisher<ScheduleModel, Error> {
        isLoading = true
        errorMessage = nil
        
        return repository.createSchedule(schedule)
            .handleEvents(
                receiveOutput: { [weak self] createdSchedule in
                    self?.currentSchedule = createdSchedule  // 현재 스케줄로 설정
                    self?.addToScheduleList(createdSchedule) // 리스트에 추가
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
    
    // 특정 UID로 스케줄을 로드하고 현재 스케줄로 설정
    func load(uid: String) -> AnyPublisher<ScheduleModel, Error> {
        isLoading = true
        errorMessage = nil
        
        return repository.readSchedule(scheduleModelUID: uid)
            .handleEvents(
                receiveOutput: { [weak self] schedule in
                    self?.currentSchedule = schedule  // 현재 스케줄로 설정
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
    func loadList(page: Int = 0, itemsPerPage: Int = 20) -> AnyPublisher<[ScheduleModel], Error> {
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
    
    // 스케줄을 업데이트하고 현재 스케줄과 리스트에 자동 반영
    func update(_ schedule: ScheduleModel) -> AnyPublisher<ScheduleModel, Error> {
        isLoading = true
        errorMessage = nil
        
        return repository.updateSchedule(schedule)
            .handleEvents(
                receiveOutput: { [weak self] updatedSchedule in
                    self?.currentSchedule = updatedSchedule     // 현재 스케줄 업데이트
                    self?.updateInScheduleList(updatedSchedule) // 리스트에서도 업데이트
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
        
        return repository.deleteSchedule(scheduleModelUID: uid)
            .handleEvents(
                receiveOutput: { [weak self] _ in
                    self?.removeFromScheduleList(uid: uid)  // 리스트에서 제거
                    if self?.currentSchedule?.uid == uid {
                        self?.currentSchedule = nil         // 현재 스케줄이면 nil로 설정
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
    
    // MARK: - 비즈니스 로직 (리액티브)
    
    /// 현재 스케줄에 장소를 추가 (중복체크, 최대개수 검증 포함)
    func addPlaceToSchedule(_ place: PlaceModel) -> AnyPublisher<ScheduleModel, Error> {
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
    
    /// 현재 스케줄에서 특정 인덱스의 장소를 제거
    func removePlaceFromSchedule(at index: Int) -> AnyPublisher<ScheduleModel, Error> {
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
    
    // MARK: - Private Helpers
    
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
    
    /// 스케줄 리스트에 새 스케줄 추가 (중복 체크)
    private func addToScheduleList(_ schedule: ScheduleModel) {
        if !scheduleList.contains(where: { $0.uid == schedule.uid }) {
            scheduleList.append(schedule)
        }
    }
    
    /// 스케줄 리스트에서 기존 스케줄을 업데이트된 버전으로 교체
    private func updateInScheduleList(_ schedule: ScheduleModel) {
        if let index = scheduleList.firstIndex(where: { $0.uid == schedule.uid }) {
            scheduleList[index] = schedule
        }
    }
    
    /// 스케줄 리스트에서 특정 UID의 스케줄 제거
    private func removeFromScheduleList(uid: String) {
        scheduleList.removeAll { $0.uid == uid }
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
    
   

//
//  FeedViewModel.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI
import Combine

class ScheduleVM: ObservableObject {
    
    // MARK: - Published Properties (UI 상태)
    @Published var schedules: [ScheduleModel] = []
    @Published var selectedSchedule: ScheduleModel?
    @Published var filteredSchedules: [ScheduleModel] = []
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showUpcomingOnly = false
    
    // MARK: - Services
    private let scheduleService: ScheduleService
    private var cancellables = Set<AnyCancellable>()
    
    init(scheduleService: ScheduleService) {
        self.scheduleService = scheduleService
        setupBindings()
        setupSearchAndFilter()
        loadInitialData()
    }
    
    // MARK: - Service Bindings (견고한 아키텍처)
    
    /// Service Publisher들을 ViewModel과 바인딩
    private func setupBindings() {
        scheduleService.schedulePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] schedule in
                self?.selectedSchedule = schedule
            }
            .store(in: &cancellables)
        
        scheduleService.scheduleListPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] schedules in
                self?.schedules = schedules
            }
            .store(in: &cancellables)
        
        scheduleService.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.isLoading = isLoading
            }
            .store(in: &cancellables)
        
        scheduleService.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.errorMessage = error
            }
            .store(in: &cancellables)
    }
    
    /// 검색 및 필터 설정 (리액티브)
    private func setupSearchAndFilter() {
        Publishers.CombineLatest3($schedules, $searchText, $showUpcomingOnly)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .map { [weak self] schedules, searchText, showUpcoming in
                self?.filterSchedules(schedules, searchText: searchText, showUpcoming: showUpcoming) ?? []
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] filtered in
                self?.filteredSchedules = filtered
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Schedule CRUD (Service 연동 + 로컬 관리)
    
    /// 빈 스케줄 모델 생성 (로컬 전용)
    func createEmptySchedule() -> ScheduleModel {
        return ScheduleModel(
            uid: UUID().uuidString,
            index: schedules.count,
            title: "",
            memo: "",
            editDate: Date(),
            d_day: Date(),
            visitPlaceList: []
        )
    }
    
    /// 스케줄 생성 (Service + 로컬 동기화)
    func create(_ schedule: ScheduleModel) {
        let newSchedule = ScheduleModel(
            uid: UUID().uuidString,
            index: schedules.count,
            title: schedule.title,
            memo: schedule.memo,
            editDate: Date(),
            d_day: schedule.d_day,
            visitPlaceList: schedule.visitPlaceList
        )
        
        // 로컬에 즉시 추가 (오프라인 우선)
        schedules.append(newSchedule)
        
        // Service 통해 서버 동기화
        scheduleService.create(newSchedule)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                        // 실패시 로컬에서 제거
                        self?.schedules.removeAll { $0.uid == newSchedule.uid }
                    }
                },
                receiveValue: { _ in
                    print("✅ Schedule synced to server: \(newSchedule.title)")
                }
            )
            .store(in: &cancellables)
    }
    
    /// 스케줄 메모 업데이트 (즉시 로컬 + 서버 동기화)
    func updateScheduleMemo(_ newMemo: String) {
        guard let schedule = selectedSchedule else { return }
        
        let updatedSchedule = ScheduleModel(
            uid: schedule.uid,
            index: schedule.index,
            title: schedule.title,
            memo: newMemo,
            editDate: Date(),
            d_day: schedule.d_day,
            visitPlaceList: schedule.visitPlaceList
        )
        
        update(updatedSchedule)
    }
    
    /// 스케줄 제목 업데이트
    func updateScheduleTitle(_ newTitle: String) {
        guard let schedule = selectedSchedule else { return }
        
        let updatedSchedule = ScheduleModel(
            uid: schedule.uid,
            index: schedule.index,
            title: newTitle,
            memo: schedule.memo,
            editDate: Date(),
            d_day: schedule.d_day,
            visitPlaceList: schedule.visitPlaceList
        )
        
        update(updatedSchedule)
    }
    
    /// D-Day 업데이트
    func updateScheduleDDay(_ newDDay: Date) {
        guard let schedule = selectedSchedule else { return }
        
        let updatedSchedule = ScheduleModel(
            uid: schedule.uid,
            index: schedule.index,
            title: schedule.title,
            memo: schedule.memo,
            editDate: Date(),
            d_day: newDDay,
            visitPlaceList: schedule.visitPlaceList
        )
        
        update(updatedSchedule)
    }
    
    /// 스케줄 업데이트 (로컬 즉시 + 서버 동기화)
    func update(_ schedule: ScheduleModel) {
        // 로컬에서 즉시 업데이트 (오프라인 우선)
        if let index = schedules.firstIndex(where: { $0.uid == schedule.uid }) {
            schedules[index] = schedule
            
            // 현재 선택된 스케줄도 업데이트
            if selectedSchedule?.uid == schedule.uid {
                selectedSchedule = schedule
            }
        }
        
        // Service 통해 서버 동기화
        scheduleService.update(schedule)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                        // 필요시 로컬 롤백 로직
                    }
                },
                receiveValue: { _ in
                    print("✅ Schedule synced: \(schedule.title)")
                }
            )
            .store(in: &cancellables)
    }
    
    /// 스케줄 삭제 (로컬 즉시 + 서버 동기화)
    func delete(scheduleUID: String) {
        // 로컬에서 즉시 삭제
        schedules.removeAll { $0.uid == scheduleUID }
        
        // 선택된 스케줄이면 클리어
        if selectedSchedule?.uid == scheduleUID {
            clearSelection()
        }
        
        // Service 통해 서버 동기화
        scheduleService.delete(uid: scheduleUID)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                        // 필요시 로컬 복원 로직
                    }
                },
                receiveValue: { _ in
                    print("🗑️ Schedule deleted: \(scheduleUID)")
                }
            )
            .store(in: &cancellables)
    }
        
    /// 서버에서 스케줄 리스트 로드
    func loadSchedules() {
        scheduleService.loadList(page: 0)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    /// 더 많은 스케줄 로드 (페이징)
    func loadMoreSchedules(page: Int) {
        scheduleService.loadList(page: page)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    /// 특정 스케줄 로드
    func loadSchedule(uid: String) {
        scheduleService.load(uid: uid)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Selection Management
    
    /// 스케줄 선택
    func selectSchedule(_ schedule: ScheduleModel) {
        selectedSchedule = schedule
    }
    
    /// 선택 해제
    func clearSelection() {
        selectedSchedule = nil
    }
    
    // MARK: - UI Helper Methods
    
    /// 검색 텍스트 클리어
    func clearSearch() {
        searchText = ""
    }
    
    /// 다가오는 스케줄 필터 토글
    func toggleUpcomingFilter() {
        showUpcomingOnly.toggle()
    }
    
    /// 에러 메시지 클리어
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - SwiftUI Bindings
    
    /// 스케줄 메모 바인딩
    var scheduleMemomBinding: Binding<String> {
        Binding<String>(
            get: { self.selectedSchedule?.memo ?? "" },
            set: { newValue in
                self.updateScheduleMemo(newValue)
            }
        )
    }
    
    // MARK: - Computed Properties
    
    /// D-Day 텍스트 계산
    var dDayText: String? {
        guard let dDay = selectedSchedule?.d_day else { return nil }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let targetDay = calendar.startOfDay(for: dDay)
        let components = calendar.dateComponents([.day], from: today, to: targetDay)
        
        if let days = components.day {
            if days == 0 {
                return "D-Day"
            } else if days > 0 {
                return "D-\(days)"
            } else {
                return "D+\(abs(days))"
            }
        }
        
        return nil
    }
    
    /// 빈 상태 표시 여부
    var showEmptyState: Bool {
        !isLoading && filteredSchedules.isEmpty
    }
    
    // MARK: - Private Helpers
    
    /// 스케줄 필터링
    private func filterSchedules(_ schedules: [ScheduleModel], searchText: String, showUpcoming: Bool) -> [ScheduleModel] {
        var filtered = schedules
        
        // 검색어 필터
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.memo.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // 다가오는 스케줄만 보기
        if showUpcoming {
            filtered = filtered.filter { $0.d_day > Date() }
                .sorted { $0.d_day < $1.d_day }
        }
        
        return filtered
    }
    
    /// 에러 핸들링
    private func handleError(_ error: Error) {
        if let scheduleError = error as? ScheduleError {
            errorMessage = scheduleError.localizedDescription
        } else {
            errorMessage = error.localizedDescription
        }
    }
    
    /// 초기 데이터 로드
    private func loadInitialData() {
        // 오프라인 우선: 로컬 데이터 먼저 로드
        schedules = DummyPack.sampleSchedules
        
        // 백그라운드에서 서버 동기화
        loadSchedules()
    }
}

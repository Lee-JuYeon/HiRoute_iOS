//
//  PlanVM.swift
//  HiRoute
//
//  Created by Jupond on 12/3/25.
//
import Combine
import SwiftUI

class PlanVM: ObservableObject {
    
    // MARK: - Published Properties (UI 상태)
    @Published var currentPlan: [VisitPlaceModel] = []
    @Published var selectedVisitPlace: VisitPlaceModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Services (메소드 호출만)
    private let scheduleService: ScheduleService
    private let placeService: PlaceService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 다른 ViewModel과의 소통용 Publishers
    private let currentScheduleSubject = CurrentValueSubject<ScheduleModel?, Never>(nil)
    
    init(scheduleService: ScheduleService, placeService: PlaceService) {
        self.scheduleService = scheduleService
        self.placeService = placeService
        
        setupBindings()
    }
    
    // MARK: - Service Bindings (안전한 패턴)
    
    private func setupBindings() {
        // ScheduleService의 현재 스케줄 구독
        scheduleService.schedulePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] schedule in
                self?.handleScheduleChange(schedule)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Plan Management (VisitPlace CRUD)
    
    /// 스케줄에 장소 추가
    func addPlaceToSchedule(_ place: PlaceModel) {
        guard let schedule = getCurrentSchedule() else {
            errorMessage = "선택된 스케줄이 없습니다"
            return
        }
        
        // 중복 체크
        guard !currentPlan.contains(where: { $0.placeModel.uid == place.uid }) else {
            errorMessage = "이미 추가된 장소입니다"
            return
        }
        
        let newVisitPlace = VisitPlaceModel(
            uid: UUID().uuidString,
            index: currentPlan.count,
            memo: "",
            placeModel: place,
            files: []
        )
        
        // 로컬에 즉시 추가
        currentPlan.append(newVisitPlace)
        
        // Service를 통해 서버 동기화
        let updatedSchedule = updateScheduleWithNewPlan(schedule)
        syncScheduleToService(updatedSchedule)
    }
    
    /// 방문 장소 제거
    func removeVisitPlace(at index: Int) {
        guard let schedule = getCurrentSchedule() else { return }
        guard index < currentPlan.count else { return }
        
        // 로컬에서 즉시 제거
        currentPlan.remove(at: index)
        
        // 인덱스 재정렬
        reorderVisitPlaces()
        
        // Service 동기화
        let updatedSchedule = updateScheduleWithNewPlan(schedule)
        syncScheduleToService(updatedSchedule)
    }
    
    /// 방문 장소 순서 변경
    func moveVisitPlace(from source: Int, to destination: Int) {
        guard let schedule = getCurrentSchedule() else { return }
        
        // 로컬에서 순서 변경
        let movedPlace = currentPlan.remove(at: source)
        currentPlan.insert(movedPlace, at: destination)
        
        // 인덱스 재정렬
        reorderVisitPlaces()
        
        // Service 동기화
        let updatedSchedule = updateScheduleWithNewPlan(schedule)
        syncScheduleToService(updatedSchedule)
    }
    
    /// 방문 장소 메모 업데이트
    func updateVisitPlaceMemo(visitPlaceUID: String, newMemo: String) {
        guard let schedule = getCurrentSchedule() else { return }
        
        // 로컬에서 메모 업데이트
        if let index = currentPlan.firstIndex(where: { $0.uid == visitPlaceUID }) {
            currentPlan[index] = VisitPlaceModel(
                uid: currentPlan[index].uid,
                index: currentPlan[index].index,
                memo: newMemo,
                placeModel: currentPlan[index].placeModel,
                files: currentPlan[index].files
            )
            
            // Service 동기화
            let updatedSchedule = updateScheduleWithNewPlan(schedule)
            syncScheduleToService(updatedSchedule)
        }
    }
    
    // MARK: - Selection Management
    
    func selectVisitPlace(_ visitPlace: VisitPlaceModel) {
        selectedVisitPlace = visitPlace
    }
    
    func clearSelection() {
        selectedVisitPlace = nil
    }
    
    // MARK: - External Integration (다른 ViewModel과 소통)
    
    /// Schedule이 변경되었을 때 처리
    func handleScheduleChange(_ schedule: ScheduleModel?) {
        if let schedule = schedule {
            currentPlan = schedule.visitPlaceList
            currentScheduleSubject.send(schedule)
        } else {
            currentPlan = []
            clearSelection()
            currentScheduleSubject.send(nil)
        }
    }
    
    // MARK: - SwiftUI Bindings
    
    func visitPlaceMemoBinding(for visitPlaceUID: String) -> Binding<String> {
        Binding<String>(
            get: {
                self.currentPlan.first(where: { $0.uid == visitPlaceUID })?.memo ?? ""
            },
            set: { newValue in
                self.updateVisitPlaceMemo(visitPlaceUID: visitPlaceUID, newMemo: newValue)
            }
        )
    }
    
    // MARK: - Private Helpers
    
    private func getCurrentSchedule() -> ScheduleModel? {
        return currentScheduleSubject.value
    }
    
    private func updateScheduleWithNewPlan(_ schedule: ScheduleModel) -> ScheduleModel {
        return ScheduleModel(
            uid: schedule.uid,
            index: schedule.index,
            title: schedule.title,
            memo: schedule.memo,
            editDate: Date(),
            d_day: schedule.d_day,
            visitPlaceList: currentPlan
        )
    }
    
    private func syncScheduleToService(_ schedule: ScheduleModel) {
        scheduleService.update(schedule)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { _ in
                    print("✅ Plan synced to server")
                }
            )
            .store(in: &cancellables)
    }
    
    private func reorderVisitPlaces() {
        currentPlan = currentPlan.enumerated().map { index, visitPlace in
            VisitPlaceModel(
                uid: visitPlace.uid,
                index: index,
                memo: visitPlace.memo,
                placeModel: visitPlace.placeModel,
                files: visitPlace.files
            )
        }
    }
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
    }
    
    deinit {
        print("✅ PlanViewModel deinit")
    }
}

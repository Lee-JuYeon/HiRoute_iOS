//
//  FeedViewModel.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI
import Combine
import Foundation
import Combine

/**
 * ScheduleViewModel (에디팅 상태 방식)
 * - @Published 에디팅 상태로 성능 최적화
 * - 완료시에만 실제 업데이트
 * - 취소/되돌리기 기능 지원
 */
final class ScheduleVM: ObservableObject {
    
    // MARK: - Published Properties (UI 상태)
    @Published var schedules: [ScheduleModel] = []
    @Published var selectedSchedule: ScheduleModel?
    @Published var filteredSchedules: [ScheduleModel] = []
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    internal let scheduleService: ScheduleService
    internal var cancellables = Set<AnyCancellable>()
    
    /**
     * 모든 바인딩에 대한 통합 접근점
     * - 사용법: scheduleVM.bindings.title, scheduleVM.bindings.memo, scheduleVM.bindings.dDay
     * - 편집 상태 자동 관리
     * - 메모리 효율적인 바인딩 생성
     */
    internal lazy var scheduleBindings: ScheduleBindings = ScheduleBindings(vm: self)
    internal lazy var scheduleCRUD : ScheduleCRUD = ScheduleCRUD(vm: self)
    
    init(scheduleService: ScheduleService) {
        self.scheduleService = scheduleService
        print("ScheduleViewModel, init // Success : 에디팅 상태 방식 ViewModel 초기화")
    }
    
    // MARK: - Lifecycle
    
    func initData() {
        /*
         TODO :
         1. 처음 앱을 켜서 보여지는 데이터는 '오프라인 데이터'임.
         2. 페이지네이션이라던가 새로고침 등이 있을 경우 그제서야 서버로부터 데이터를 호출하는 방향으로.
         */
        schedules = DummyPack.sampleSchedules
        print("ScheduleViewModel, loadInitialData // Info : 로컬 데이터 우선 로드 - \(schedules.count)개")
    }
    
    
    // 로딩 상태 설정 (internal로 노출)
    internal func setLoading(_ loading: Bool) {
        isLoading = loading
    }
    
    // 에러 처리 (internal로 노출)
    internal func handleError(_ error: Error) {
        if let scheduleError = error as? ScheduleError {
            errorMessage = scheduleError.localizedDescription
        } else {
            errorMessage = error.localizedDescription
        }
    }
    
    
    // schedule crud
    func createSchedule(title: String, memo: String, dDay: Date) {
        scheduleCRUD.create(title: title, memo: memo, dDay: dDay)
    }
    
    func loadScheduleList() {
        scheduleCRUD.readAll()
    }
    
    func loadSchedule(uid: String) {
        scheduleCRUD.read(uid: uid)
    }
    
    func deleteSchedule(scheduleUID: String) {
        scheduleCRUD.delete(scheduleUID: scheduleUID)
    }
    
    func updateSchedule(schedule : ScheduleModel) {
        scheduleCRUD.update(schedule)
    }
      
    func updateScheduleInfo(uid: String, title: String, memo: String, dDay: Date){
        scheduleCRUD.updateScheduleInfo(uid: uid, title: title, memo: memo, dDay: dDay)
    }
    
    // 일정 선택 + 에디팅 상태 초기화
    func selectSchedule(_ schedule: ScheduleModel) {
        selectedSchedule = schedule
    }
    
    // 새로고침
    func refreshScheduleList(){
        scheduleCRUD.refreshScheduleList()
    }
    
    deinit {
        cancellables.removeAll()
        print("ScheduleViewModel, deinit // Success : ScheduleViewModel 해제 완료")
    }
}

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
    
    @Published var planTitle = ""
    @Published var planMemo = ""
    @Published var planDDay = Date()
    
    private var originalTitle = ""
    private var originalMemo = ""
    private var originalDDay = Date()
    
    internal let scheduleService: ScheduleService
    internal var cancellables = Set<AnyCancellable>()
    
    /**
     * 모든 바인딩에 대한 통합 접근점
     * - 사용법: scheduleVM.bindings.title, scheduleVM.bindings.memo, scheduleVM.bindings.dDay
     * - 편집 상태 자동 관리
     * - 메모리 효율적인 바인딩 생성
     */
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
//        schedules = DummyPack.sampleSchedules
        self.loadScheduleList()
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
    func createSchedule(title: String, memo: String, dDay: Date, result: @escaping (Bool) -> Void) {
        scheduleCRUD.create(title: title, memo: memo, dDay: dDay, result: result)
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
    
    
    // 편집 시작 (일정 선택시)
    func startEditing(_ schedule: ScheduleModel) {
        selectedSchedule = schedule
        planTitle = schedule.title
        planMemo = schedule.memo
        planDDay = schedule.d_day
        
        /*
         원본 백업
         왜 originalTitle,Memo,DDay를 변수 선언했냐면 planview에서 실제로 수정이 일어났다는걸을 확인한 이후에 로컬과 서버에 변경요청해야한다.
         하지만 originalTitle,Memo,DDay없이 실질적으로 수정이 어디서 일어났는지 확인하기가 어려워 확인용으로 변수 선언함.
         */
        originalTitle = schedule.title
        originalMemo = schedule.memo
        originalDDay = schedule.d_day
    }
    
    // 편집 완료 (확인 버튼)
    func finishEditing() {
        guard let schedule = selectedSchedule else { return }
        updateScheduleInfo(uid: schedule.uid, title: planTitle, memo: planMemo, dDay: planDDay)
    }
    
    // 편집 취소
    func cancelEditing() {
        guard let schedule = selectedSchedule else { return }
        planTitle = schedule.title
        planMemo = schedule.memo
        planDDay = schedule.d_day
    }
    
    // 변경사항 확인
    var hasChanges: Bool {
        return planTitle != originalTitle ||
               planMemo != originalMemo ||
               planDDay != originalDDay
    }
    
    func finishEditingIfChanged() -> Bool {
        guard hasChanges else { return false }
        guard let schedule = selectedSchedule else { return false }
        
        // UPDATE 전용으로 단순화
        updateScheduleInfo(uid: schedule.uid, title: planTitle, memo: planMemo, dDay: planDDay)
        return true
    }
    
    deinit {
        cancellables.removeAll()
        print("ScheduleViewModel, deinit // Success : ScheduleViewModel 해제 완료")
    }
}

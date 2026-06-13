//
//  ScheduleVM.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI
import Foundation
import CoreData
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
    @Published var currentFilter: ListFilterType = .DEFAULT

    var sortedSchedules: [ScheduleModel] {
        switch currentFilter {
        case .DEFAULT:
            return schedules.sorted { $0.index < $1.index }
        case .NEWEST:
            return schedules.sorted { $0.editDate > $1.editDate }
        case .OLDEST:
            return schedules.sorted { $0.editDate < $1.editDate }
        }
    }
    
    @Published var selectedSchedule: ScheduleModel?
    private var originalSchedule: ScheduleModel?
    private var isEditing: Bool = false

    
    var currentPlans: [PlanModel] {
        selectedSchedule?.planList ?? []
    }

    var currentPlaces: [PlaceModel] {
        selectedSchedule?.planList.map { $0.placeModel } ?? []
    }
    
    func getFiles(planUID: String) -> [FileModel] {
        selectedSchedule?.planList.first { $0.uid == planUID }?.files ?? []
    }

    
    var currentFiles: [FileModel] {
        selectedSchedule?.planList.flatMap { $0.files } ?? []
    }
    
    func getFilesForPlan(planUID: String) -> [FileModel] {
        selectedSchedule?.planList.first { $0.uid == planUID }?.files ?? []
    }


    
    @Published var searchText = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var progress: Double = 0.0

    // MARK: - PlanView UI State
    //
    // 순수 데이터 홀더. 하위 뷰에서 scheduleVM.planEvent.selectPlan()으로 값 설정.
    // 화면 전환은 NavigationVM.navigateTo()가 담당.
    @Published var currentPlanModel: PlanModel? = nil

    internal let scheduleService: ScheduleService
    internal let planService: PlanService
    
    internal var cancellables = Set<AnyCancellable>()
    
    /**
     * 모든 바인딩에 대한 통합 접근점
     * - 사용법: scheduleVM.bindings.title, scheduleVM.bindings.memo, scheduleVM.bindings.dDay
     * - 편집 상태 자동 관리
     * - 메모리 효율적인 바인딩 생성
     */
    
    internal lazy var planBindings: PlanBindings = PlanBindings(vm: self)
    
    internal lazy var planCRUD: PlanCRUD = PlanCRUD(vm: self)
    internal lazy var fileCRUD: FileCRUD = FileCRUD(vm: self)
    internal lazy var scheduleCRUD : ScheduleCRUD = ScheduleCRUD(vm: self)
    /// PlanEvent: 하위 뷰에서 Plan 관련 이벤트를 VM으로 전달하는 중개자.
    /// - lazy var: 최초 접근 시점에 한 번만 생성 (불필요한 초기 비용 없음)
    /// - PlanEvent는 struct이므로 힙 할당 없이 인라인 저장됨
    /// - 내부에서 weak var로 self(ScheduleVM)를 참조 → 순환 참조 없음
    /// - 기존 planBindings, planCRUD, fileCRUD, scheduleCRUD와 동일한 패턴
    internal lazy var planEvent: PlanEvent = PlanEvent(vm: self)
    internal lazy var scheduleEvent: ScheduleEvent = ScheduleEvent(vm: self)
    
    
    init(scheduleService: ScheduleService, planService: PlanService) {
        self.scheduleService = scheduleService
        self.planService = planService
        print("ScheduleVM, init")
    }
      
    
    // MARK: - Lifecycle
    
    func initData() {
        // 1. CoreData 즉시 로드 → UI 바로 표시
        self.readAllSchedule()
        print("ScheduleViewModel, initData // Info : 로컬 데이터 우선 로드")

        // 2. 백그라운드 서버 동기화 → 완료 후 UI 갱신
        scheduleService.syncWithServer()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.readAllSchedule()
                print("ScheduleViewModel, initData // Info : 서버 동기화 완료, UI 갱신")
            }
            .store(in: &cancellables)
    }
    
    
    // 로딩 상태 설정 (internal로 노출)
    internal func setLoading(_ loading: Bool) {
        isLoading = loading
        if loading {
            errorMessage = nil
        }
    }
    

    
    internal func setProgress(_ getProgress: Double) {
        progress = getProgress
    }
    
    // 에러 처리 (internal로 노출)
    internal func handleError(_ error: Error) {
        let message: String
        switch error {
        case let scheduleError as ScheduleError:
            message = "일정: \(scheduleError.localizedDescription)"
        case let planError as PlanError:
            message = "계획: \(planError.localizedDescription)"
        case let fileError as FileError:
            message = "파일: \(fileError.localizedDescription)"
        default:
            message = "알 수 없는 오류: \(error.localizedDescription)"
        }
        errorMessage = message
        print("ScheduleVM, handleError // Error : \(message)")
    }
    
    
    // schedule crud
    func createSchedule(title: String, memo: String, dDay: Date, planList : [PlanModel], result: @escaping (Bool) -> Void) {
        scheduleCRUD.create(title: title, memo: memo, dDay: dDay, planList: planList, result: result)
    }
    
    func readAllSchedule() {
        scheduleCRUD.readAll()
    }
    
    func readSchedule(uid: String) {
        scheduleCRUD.read(uid: uid)
    }
    
    func deleteSchedule(scheduleUID: String) {
        scheduleCRUD.delete(scheduleUID: scheduleUID)
    }
    
    func updateSchedule(schedule : ScheduleModel) {
        scheduleCRUD.update(schedule)
    }
      
    func updateScheduleIndex(from: Int, to: Int) {
        scheduleCRUD.updateIndex(from: from, to: to)
    }

    func updateScheduleInfo(uid: String, title: String, memo: String, dDay: Date, completion: @escaping (Bool) -> Void = { _ in }){
        scheduleCRUD.updateScheduleInfo(uid: uid, title: title, memo: memo, dDay: dDay, completion: completion)
    }
    
    // ScheduleVM에서 기존 메서드 수정
    internal func updateUiSchedule(_ plan: PlanModel) {
        guard let schedule = selectedSchedule else { return }

        var updatedPlanList = schedule.planList
        if let index = updatedPlanList.firstIndex(where: { $0.uid == plan.uid }) {
            updatedPlanList[index] = plan
        } else {
            updatedPlanList.append(plan)
        }

        // [2026-05-26] copy() 헬퍼로 chatHistory 자동 preserve.
        selectedSchedule = schedule.copy(
            editDate: schedule.editDate,
            planList: updatedPlanList
        )

        // ✅ currentPlanModel 도 같이 sync — PlaceView/PlaceBottomSection이 이걸 보고 있어서
        // 안 맞추면 메모/파일 수정 후 화면 갱신 안 됨 (나갔다 돌아와야 보이는 문제).
        if currentPlanModel?.uid == plan.uid {
            currentPlanModel = plan
        }

        print("ScheduleVM, updateCurrentScheduleWithPlan // Success : Plan 업데이트 완료")
    }
    
    func updateUiTitle(_ title: String) {
        guard let schedule = selectedSchedule else { return }
        // [2026-05-26] copy() — chatHistory 자동 preserve. editDate는 명시적으로 기존 값 유지.
        selectedSchedule = schedule.copy(title: title, editDate: schedule.editDate)
    }

    func updateUiMemo(_ memo: String) {
        guard let schedule = selectedSchedule else { return }
        selectedSchedule = schedule.copy(memo: memo, editDate: schedule.editDate)
    }

    func updateUiDDay(_ dDay: Date) {
        guard let schedule = selectedSchedule else { return }
        selectedSchedule = schedule.copy(editDate: schedule.editDate, d_day: dDay)
    }

    func updateUiEditDate() {
        guard let schedule = selectedSchedule else { return }
        selectedSchedule = schedule.copy(editDate: Date())
    }
    
    // ScheduleVM.swift
    func updateUiPlanMemo(planUID: String, newMemo: String) {
        guard let schedule = selectedSchedule else { return }
        
        var updatedPlanList = schedule.planList
        if let planIndex = updatedPlanList.firstIndex(where: { $0.uid == planUID }) {
            let updatedPlan = PlanModel(
                uid: updatedPlanList[planIndex].uid,
                index: updatedPlanList[planIndex].index,
                memo: newMemo,  
                placeModel: updatedPlanList[planIndex].placeModel,
                files: updatedPlanList[planIndex].files
            )
            
            updatedPlanList[planIndex] = updatedPlan

            // [2026-05-26] copy() — chatHistory 자동 preserve.
            selectedSchedule = schedule.copy(
                editDate: schedule.editDate,
                planList: updatedPlanList
            )

            if currentPlanModel?.uid == planUID {
                currentPlanModel = updatedPlan
            }

            print("ScheduleVM, updateUiPlanMemo // Success : Plan 메모 메모리 업데이트 완료")
        }
    }
    
    // 일정 선택
    func selectSchedule(_ schedule: ScheduleModel) {
        selectedSchedule = schedule
    }
    
    // 새로고침
    func refreshScheduleList(){
        scheduleCRUD.refreshScheduleList()
    }
    
    
    /// 편집 시작 (일정 선택시).
    /// 편집 세션당 1회만 원본 백업. 뷰 재생성으로 onAppear가 재실행되어도
    /// isEditing 가드가 originalSchedule 덮어쓰기를 방지.
    func startEditing(_ schedule: ScheduleModel) {
        guard !isEditing else { return }
        selectedSchedule = schedule
        originalSchedule = schedule
        isEditing = true
    }

    // 편집 완료 (확인 버튼)
    func finishEditing() {
        guard let schedule = selectedSchedule else { return }
        updateSchedule(schedule: schedule)
        isEditing = false
        originalSchedule = nil
    }

    // 편집 취소
    func cancelEditing() {
        selectedSchedule = originalSchedule
        isEditing = false
        originalSchedule = nil
    }

    
    // 변경사항 확인
    var hasChanges: Bool {
        guard let original = originalSchedule,
              let current = selectedSchedule else { return false }
        
        // Schedule 레벨 변경사항
        let scheduleChanged = current.title != original.title ||
                             current.memo != original.memo ||
                             current.d_day != original.d_day ||
                             current.planList.count != original.planList.count
        
        // Plan 레벨 변경사항 확인
        for currentPlan in current.planList {
            if let originalPlan = original.planList.first(where: { $0.uid == currentPlan.uid }) {
                // 메모 변경 체크
                if currentPlan.memo != originalPlan.memo {
                    print("🔍 Plan 메모 변경 감지: '\(originalPlan.memo)' → '\(currentPlan.memo)'")
                    return true
                }
                
                // 파일 배열 통째 비교 (추가/삭제 + 모든 필드 변경 감지)
                if currentPlan.files != originalPlan.files {
                    return true
                }
            }
        }
            
        
        return scheduleChanged
    }
    
    
    func finishEditingIfChanged(completion: @escaping (Bool) -> Void = { _ in }) -> Bool {
        guard hasChanges else {
            completion(false)
            return false
        }
        guard let schedule = selectedSchedule else {
            completion(false)
            return false
        }
        
        // ✅ 전체 schedule 업데이트 (plan 포함)
        // [2026-05-26] copy() — chatHistory 자동 preserve.
        let updatedSchedule = schedule.copy(editDate: Date())
        updateSchedule(schedule: updatedSchedule)
        completion(true)
        return true
    }

    func clearSelection() {
        selectedSchedule = nil
        originalSchedule = nil
        isEditing = false
    }

    
    func createPlan(placeModel: PlaceModel, files: [FileModel] = []) {
        guard let scheduleUID = selectedSchedule?.uid else {
            handleError(ScheduleError.notFound)
            return
        }
        planCRUD.create(placeModel, scheduleUID: scheduleUID, files: files)
    }
    
    func readPlan(planUID: String) {
        planCRUD.read(uid: planUID)
    }
    
    func readAllPlans() {
        guard let scheduleUID = selectedSchedule?.uid else { return }
        planCRUD.readAll(scheduleUID: scheduleUID)
    }
    
    func updatePlan(_ plan: PlanModel) {
        planCRUD.update(plan)
    }
    
    func updatePlanIndex(from: Int, to: Int) {
        planCRUD.updateIndex(from: from, to: to)
    }
    
    func updatePlanMemo(planUID: String, newMemo: String) {
        planCRUD.updateMemo(planUID: planUID, newMemo: newMemo)
    }
    
    func deletePlan(planUID: String) {
        planCRUD.delete(planUID: planUID)
    }
    
    func createFile(planUID: String, data: Data? = nil, fileName: String? = nil, fileType: String? = nil, files: [FileModel] = []) {
        fileCRUD.create(planUID: planUID, files: files, data: data, fileName: fileName, fileType: fileType)
    }
    
    func readFile(fileUID: String) {
        fileCRUD.read(fileUID: fileUID)
    }
    
    func readAllFiles(planUID: String) {
        fileCRUD.readAll(planUID: planUID)
    }
    
    func updateFile(fileUID: String, newFileName: String) {
        fileCRUD.update(fileUID: fileUID, newFileName: newFileName)
    }
    
    func deleteFile(fileUID: String) {
        fileCRUD.delete(fileUID: fileUID)
    }
    
    internal func updateFiles(planUID: String, newFiles: [FileModel]) {
        guard let schedule = selectedSchedule else { return }
        
        var updatedPlanList = schedule.planList
        if let planIndex = updatedPlanList.firstIndex(where: { $0.uid == planUID }) {
            let updatedPlan = PlanModel(
                uid: updatedPlanList[planIndex].uid,
                index: updatedPlanList[planIndex].index,
                memo: updatedPlanList[planIndex].memo,
                placeModel: updatedPlanList[planIndex].placeModel,
                files: newFiles // ✅ 새 파일 리스트로 업데이트
            )
            
            updatedPlanList[planIndex] = updatedPlan

            // [2026-05-26] copy() — chatHistory 자동 preserve.
            selectedSchedule = schedule.copy(
                editDate: schedule.editDate,
                planList: updatedPlanList
            )
            print("ScheduleVM, updatePlanFiles // Success : Plan 파일 업데이트 완료 - \(newFiles.count)개")
        }
    }
    
    internal func removeCurrentSchedulePlan(planUID: String) {
        guard let schedule = selectedSchedule else { return }

        let updatedPlanList = schedule.planList.filter { $0.uid != planUID }

        // [2026-05-26] copy() — chatHistory 자동 preserve.
        // updateModel wrap 제거 (newModel.chatHistory를 그대로 복사하던 패스스루였음).
        selectedSchedule = schedule.copy(
            editDate: schedule.editDate,
            planList: updatedPlanList
        )
        print("ScheduleVM, removeCurrentSchedulePlan // Success : Plan 제거 완료")
    }
    
    // MARK: - File Cache Management
    internal func updateSavedFilesForPlan(planUID: String, newFiles: [FileModel]) {
        guard let schedule = selectedSchedule else { return }
        var updatedPlanList = schedule.planList

        if let planIndex = updatedPlanList.firstIndex(where: { $0.uid == planUID }) {
            let updatedPlan = PlanModel(
                uid: updatedPlanList[planIndex].uid,
                index: updatedPlanList[planIndex].index,
                memo: updatedPlanList[planIndex].memo,
                placeModel: updatedPlanList[planIndex].placeModel,
                files: newFiles
            )
            
            updatedPlanList[planIndex] = updatedPlan

            // [2026-05-26] copy() — chatHistory 자동 preserve.
            selectedSchedule = schedule.copy(
                editDate: schedule.editDate,
                planList: updatedPlanList
            )
            print("ScheduleVM, updatePlanFiles // Success : Plan 파일 업데이트 완료 - \(newFiles.count)개")
        }
    }
    
    
    deinit {
        cancellables.removeAll()
        print("ScheduleViewModel, deinit // Success : ScheduleViewModel 해제 완료")
    }
}

extension ScheduleVM {
    func printAllCoreData() {
        print("\n" + String(repeating: "=", count: 60))
        print("🔍 REAL CORE DATA VS VIEWMODEL")
        print(String(repeating: "=", count: 60))
        
        // 1. ViewModel 상태
        print("\n📱 VIEWMODEL STATE:")
        print("schedules.count: \(schedules.count)")
        print("selectedSchedule: \(selectedSchedule?.title ?? "nil")")
        
        // 2. 실제 CoreData 조회
        print("\n💾 REAL CORE DATA:")
        LocalDB.shared.readAllSchedules { realSchedules in
            DispatchQueue.main.async {
                print("Real DB count: \(realSchedules.count)")
                realSchedules.forEach { schedule in
                    print("- \(schedule.title) (Plans: \(schedule.planList.count))")
                    schedule.planList.forEach { plan in
                        print("  └─ Plan[\(plan.index)]: '\(plan.placeModel.title)'")
                    }
                }
                
                // 3. 동기화 문제 확인
                if realSchedules.count != self.schedules.count {
                    print("\n❌ SYNC PROBLEM: DB(\(realSchedules.count)) != VM(\(self.schedules.count))")
                    print("🔧 Fix: Call initData() or loadData()")
                }
            }
        }
        
        print(String(repeating: "=", count: 60))
    }
}

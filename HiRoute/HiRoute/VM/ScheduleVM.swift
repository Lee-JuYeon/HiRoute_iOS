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
import CoreData

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
    private var originalSchedule: ScheduleModel?

    
    var currentPlans: [PlanModel] {
        selectedSchedule?.planList ?? []
    }

    var currentPlaces: [PlaceModel] {
        selectedSchedule?.planList.map { $0.placeModel } ?? []
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
    
    
    init(scheduleService: ScheduleService, planService: PlanService) {
        self.scheduleService = scheduleService
        self.planService = planService
        print("ScheduleVM, init")
    }
      
    
    // MARK: - Lifecycle
    
    func initData() {
        /*
         TODO :
         1. 처음 앱을 켜서 보여지는 데이터는 '오프라인 데이터'임.
         2. 페이지네이션이라던가 새로고침 등이 있을 경우 그제서야 서버로부터 데이터를 호출하는 방향으로.
         */
//        schedules = DummyPack.sampleSchedules
        self.readAllSchedule()
        print("ScheduleViewModel, loadInitialData // Info : 로컬 데이터 우선 로드 - \(schedules.count)개")
    }
    
    
    // 로딩 상태 설정 (internal로 노출)
    internal func setLoading(_ loading: Bool) {
        isLoading = loading
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
        
        // updateModel 제거, 직접 할당
        let newSchedule = ScheduleModel(
            uid: schedule.uid,
            index: schedule.index,
            title: schedule.title,
            memo: schedule.memo,
            editDate: schedule.editDate,
            d_day: schedule.d_day,
            planList: updatedPlanList
        )
        
        selectedSchedule = newSchedule // 직접 할당
        print("ScheduleVM, updateCurrentScheduleWithPlan // Success : Plan 업데이트 완료")
    }
    
    func updateUiTitle(_ title: String) {
        guard let schedule = selectedSchedule else { return }
        selectedSchedule = ScheduleModel(
            uid: schedule.uid,
            index: schedule.index,
            title: title,
            memo: schedule.memo,
            editDate: schedule.editDate,
            d_day: schedule.d_day,
            planList: schedule.planList
        )
    }
    
    func updateUiMemo(_ memo: String) {
        guard let schedule = selectedSchedule else { return }
        selectedSchedule = ScheduleModel(
            uid: schedule.uid,
            index: schedule.index,
            title: schedule.title,
            memo: memo,
            editDate: schedule.editDate,
            d_day: schedule.d_day,
            planList: schedule.planList
        )
    }

    func updateUiDDay(_ dDay: Date) {
        guard let schedule = selectedSchedule else { return }
        selectedSchedule = ScheduleModel(
            uid: schedule.uid,
            index: schedule.index,
            title: schedule.title,
            memo: schedule.memo,
            editDate: schedule.editDate,
            d_day: dDay,
            planList: schedule.planList
        )
    }
    
    func updateUiEditDate() {
        guard let schedule = selectedSchedule else { return }
        selectedSchedule = ScheduleModel(
            uid: schedule.uid,
            index: schedule.index,
            title: schedule.title,
            memo: schedule.memo,
            editDate: Date(), 
            d_day: schedule.d_day,
            planList: schedule.planList
        )
    }
    
    // 일정 선택
    func selectSchedule(_ schedule: ScheduleModel) {
        selectedSchedule = schedule
    }
    
    // 새로고침
    func refreshScheduleList(){
        scheduleCRUD.refreshScheduleList()
    }
    
    
    // 편집 시작 (일정 선택시)
    func startEditing(_ schedule: ScheduleModel) {
        /*
         원본 백업
         왜 originalTitle,Memo,DDay를 변수 선언했냐면 planview에서 실제로 수정이 일어났다는걸을 확인한 이후에 로컬과 서버에 변경요청해야한다.
         하지만 originalTitle,Memo,DDay없이 실질적으로 수정이 어디서 일어났는지 확인하기가 어려워 확인용으로 변수 선언함.
         */
        selectedSchedule = schedule
        originalSchedule = schedule
    }
    
    // 편집 완료 (확인 버튼)
    func finishEditing() {
        guard let schedule = selectedSchedule else { return }
        updateSchedule(schedule: schedule) // selectedSchedule 그대로 저장
    }
    
    // 편집 취소
    func cancelEditing() {
        selectedSchedule = originalSchedule // 원본으로 복구
    }

    
    // 변경사항 확인
    var hasChanges: Bool {
        guard let original = originalSchedule,
              let current = selectedSchedule else { return false }
        
        return current.title != original.title ||
               current.memo != original.memo ||
               current.d_day != original.d_day ||
               current.planList.count != original.planList.count
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
        let updatedSchedule = ScheduleModel(
            uid: schedule.uid,
            index: schedule.index,
            title: schedule.title,
            memo: schedule.memo,
            editDate: Date(),
            d_day: schedule.d_day,
            planList: schedule.planList
        )
        
        updateSchedule(schedule: updatedSchedule)
        completion(true)
        return true
    }

    func clearSelection() {
        selectedSchedule = nil
        originalSchedule = nil
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
            
            // selectedSchedule 업데이트
            let newSchedule = ScheduleModel(
                uid: schedule.uid,
                index: schedule.index,
                title: schedule.title,
                memo: schedule.memo,
                editDate: schedule.editDate,
                d_day: schedule.d_day,
                planList: updatedPlanList
            )
            
            selectedSchedule = newSchedule
            print("ScheduleVM, updatePlanFiles // Success : Plan 파일 업데이트 완료 - \(newFiles.count)개")
        }
    }
    
    internal func removeCurrentSchedulePlan(planUID: String) {
        guard let schedule = selectedSchedule else { return }
            
        let updatedPlanList = schedule.planList.filter { $0.uid != planUID }
        
        let newScheduleModel = ScheduleModel(
            uid: schedule.uid,
            index: schedule.index,
            title: schedule.title,
            memo: schedule.memo,
            editDate: schedule.editDate,
            d_day: schedule.d_day,
            planList: updatedPlanList
        )
        
        selectedSchedule = schedule.updateModel(newScheduleModel)
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

            let newSchedule = ScheduleModel(
                uid: schedule.uid,
                index: schedule.index,
                title: schedule.title,
                memo: schedule.memo,
                editDate: schedule.editDate,
                d_day: schedule.d_day,
                planList: updatedPlanList
            )
            
            selectedSchedule = newSchedule
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

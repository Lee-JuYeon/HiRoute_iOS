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
    
    @Published var files: [FileModel] = []

    @Published var selectedPlanModel: PlanModel?  // ✅ 이것만 추가하면 끝!

    @Published var searchText = ""
    
    @Published var isUploadingFile = false
    @Published var fileUploadProgress: Double = 0.0
    
    // MARK: - Dependencies & Components
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    
    @Published var scheduleTitle = ""
    @Published var scheduleMemo = ""
    @Published var scheduleDday = Date()
    
    private var originalTitle = ""
    private var originalMemo = ""
    private var originalDDay = Date()
    
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
    
    internal func setFileUploading(_ uploading: Bool) {
        isUploadingFile = uploading
    }
    
    internal func updateFileUploadProgress(_ progress: Double) {
        fileUploadProgress = progress
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
    func createSchedule(title: String, memo: String, dDay: Date, result: @escaping (Bool) -> Void) {
        scheduleCRUD.create(title: title, memo: memo, dDay: dDay, result: result)
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
        selectedSchedule = schedule
        scheduleTitle = schedule.title
        scheduleMemo = schedule.memo
        scheduleDday = schedule.d_day
        
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
        updateScheduleInfo(uid: schedule.uid, title: scheduleTitle, memo: scheduleMemo, dDay: scheduleDday)
    }
    
    // 편집 취소
    func cancelEditing() {
        guard let schedule = selectedSchedule else { return }
        scheduleTitle = schedule.title
        scheduleMemo = schedule.memo
        scheduleDday = schedule.d_day
    }
    
    // 변경사항 확인
    var hasChanges: Bool {
        return scheduleTitle != originalTitle ||
            scheduleMemo != originalMemo ||
            scheduleDday != originalDDay
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
        
        updateScheduleInfo(uid: schedule.uid, title: scheduleTitle, memo: scheduleMemo, dDay: scheduleDday, completion: completion)
        return true
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
    
    // MARK: - Schedule State Management
    internal func updateCurrentScheduleWithPlan(_ plan: PlanModel) {
        guard let schedule = selectedSchedule else { return }
        
        var updatedPlanList = schedule.planList
        if let index = updatedPlanList.firstIndex(where: { $0.uid == plan.uid }) {
            updatedPlanList[index] = plan
        } else {
            updatedPlanList.append(plan)
        }
        
        // 기존 updateModel 메서드 활용
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
        print("ScheduleVM, updateCurrentScheduleWithPlan // Success : Plan 업데이트 완료")
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
    internal func updateSavedFilesForPlan(planUID: String, files: [FileModel]) {
        self.files = self.files.filter { !($0.isSaved && $0.filePath.contains(planUID)) }
        
        let savedFiles = files.map { file in
            FileModel.saved(
                fileName: file.fileName,
                fileType: file.fileType,
                fileSize: file.fileSize,
                filePath: file.filePath,
                createdDate: file.createdDate
            )
        }
        self.files.append(contentsOf: savedFiles)
        print("ScheduleVM, updateSavedFilesForPlan // Success : 파일 캐시 업데이트 - \(savedFiles.count)개")
    }
    
    internal func updateSavedFilesFromPlan(_ plan: PlanModel) {
        files.removeAll { $0.isPendingUpload }
        
        let savedFileModels = plan.files.map { file in
            FileModel.saved(
                fileName: file.fileName,
                fileType: file.fileType,
                fileSize: file.fileSize,
                filePath: file.filePath,
                createdDate: file.createdDate
            )
        }
        files.append(contentsOf: savedFileModels)
        print("ScheduleVM, updateSavedFilesFromPlan // Success : Plan 파일 동기화 완료 - \(savedFileModels.count)개")
    }
    
    deinit {
        cancellables.removeAll()
        print("ScheduleViewModel, deinit // Success : ScheduleViewModel 해제 완료")
    }
}

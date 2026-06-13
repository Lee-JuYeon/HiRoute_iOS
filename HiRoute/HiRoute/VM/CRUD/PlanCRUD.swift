//
//  PlanCRUD.swift
//  HiRoute
//
//  Created by Jupond on 12/26/25.
//
import SwiftUI
import Combine

struct PlanCRUD {
    private weak var vm: ScheduleVM?
    
    init(vm: ScheduleVM) {
        self.vm = vm
    }
    
    func create(_ placeModel: PlaceModel, scheduleUID: String, files: [FileModel] = []) {
        print("PlanCRUD, create // Info : Plan 생성 시작 - \(placeModel.title)")
        guard let vm = vm else { return }
        
        let currentCount = vm.selectedSchedule?.planList.count ?? 0
        
        let newPlan = PlanModel(
            uid: "plan_\(UUID().uuidString)",
            index: currentCount, // ✅ 정확한 다음 인덱스
            memo: "",
            placeModel: placeModel,
            files: []
        )
        
        vm.setLoading(true)
        
        let fileList: [(Data, String, String)] = files.compactMap { file in
            if let data = extractFileData(from: file) {
                return (data, file.fileName, file.fileType)
            }
            return nil
        }
        
        vm.planService.createPlan(newPlan, scheduleUID: scheduleUID, fileList: fileList)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak vm] completion in
                    vm?.setLoading(false)
                    vm?.setProgress(0.0)
                    
                    switch completion {
                    case .finished:
                        print("PlanCRUD, create // Success : Plan 생성 완료")
                    case .failure(let error):
                        vm?.handleError(error)
                        print("PlanCRUD, create // Exception : Plan 생성 실패 - \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak vm] createdPlan in
                    guard let schedule = vm?.selectedSchedule else { return }
                        
                    // 생성된 Plan의 인덱스를 현재 리스트 끝으로 설정
                    let correctedPlan = PlanModel(
                        uid: createdPlan.uid,
                        index: schedule.planList.count, // 새 Plan은 맨 끝 인덱스
                        memo: createdPlan.memo,
                        placeModel: createdPlan.placeModel,
                        files: createdPlan.files
                    )
                    
                    var updatedPlanList = schedule.planList
                    updatedPlanList.append(correctedPlan)
                    
                    // 모든 Plan의 인덱스를 순차적으로 재할당
                    var reindexedPlanList: [PlanModel] = []
                    for (index, plan) in updatedPlanList.enumerated() {
                        let updatedPlan = PlanModel(
                            uid: plan.uid,
                            index: index,  // ← 순차적 인덱스 (0,1,2,3...)
                            memo: plan.memo,
                            placeModel: plan.placeModel,
                            files: plan.files
                        )
                        reindexedPlanList.append(updatedPlan)
                    }
                    
                    // [2026-05-26] copy() — chatHistory 자동 preserve.
                    vm?.selectedSchedule = schedule.copy(
                        editDate: schedule.editDate,
                        planList: reindexedPlanList  // ← 재정렬된 리스트
                    )
                    if !createdPlan.files.isEmpty {
                        vm?.updateFiles(planUID: createdPlan.uid, newFiles: createdPlan.files)
                    }
                    print("PlanCRUD, create // Success : selectedSchedule 업데이트 완료 - 인덱스 재정렬")
                }
            )
            .store(in: &vm.cancellables)
    }

    func read(uid: String) {
        print("PlanCRUD, read // Info : Plan 조회 - \(uid)")
        guard let vm = vm else { return }
        
        vm.setLoading(true)
        
        vm.planService.readPlan(planUID: uid)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak vm] completion in
                    vm?.setLoading(false)
                    
                    switch completion {
                    case .finished:
                        print("PlanCRUD, read // Success : Plan 조회 완료")
                    case .failure(let error):
                        vm?.handleError(error)
                        print("PlanCRUD, read // Exception : Plan 조회 실패 - \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak vm] plan in
                    vm?.updateUiSchedule(plan)
                    vm?.fileCRUD.readAll(planUID: plan.uid)
                }
            )
            .store(in: &vm.cancellables)
    }
    
    func readAll(scheduleUID: String) {
        print("PlanCRUD, readAll // Info : Plan 목록 조회 - \(scheduleUID)")
        guard let vm = vm else { return }
        
        vm.setLoading(true)
        
        vm.planService.readPlanList(scheduleUID: scheduleUID)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak vm] completion in
                    vm?.setLoading(false)
                    
                    switch completion {
                    case .finished:
                        print("PlanCRUD, readAll // Success : Plan 목록 조회 완료")
                    case .failure(let error):
                        vm?.handleError(error)
                        print("PlanCRUD, readAll // Exception : Plan 목록 조회 실패 - \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak vm] plans in
                    guard let schedule = vm?.selectedSchedule else { return }

                    // [2026-05-26] copy() — chatHistory 자동 preserve.
                    vm?.selectedSchedule = schedule.copy(
                        editDate: schedule.editDate,
                        planList: plans
                    )
                    print("PlanCRUD, readAll // Success : selectedSchedule planList 업데이트 완료 - \(plans.count)개")
                }
            )
            .store(in: &vm.cancellables)
    }
    
    func update(_ plan: PlanModel) {
        print("PlanCRUD, update // Info : Plan 전체 업데이트 - \(plan.placeModel.title)")
        guard let vm = vm else { return }
        
        vm.setLoading(true)
        
        vm.planService.updatePlan(plan)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak vm] completion in
                    vm?.setLoading(false)
                    
                    switch completion {
                    case .finished:
                        print("PlanCRUD, update // Success : Plan 전체 업데이트 완료")
                    case .failure(let error):
                        vm?.handleError(error)
                        print("PlanCRUD, update // Exception : Plan 전체 업데이트 실패 - \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak vm] updatedPlan in
                    vm?.updateUiSchedule(updatedPlan)
                    print("PlanCRUD, update // Success : selectedSchedule 업데이트 완료")
                }
            )
            .store(in: &vm.cancellables)
    }
    
    func delete(planUID: String) {
        print("PlanCRUD, delete // Info : Plan 삭제 - \(planUID)")
        guard let vm = vm else { return }
        
        vm.setLoading(true)
        
        vm.planService.deletePlan(planUID: planUID)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak vm] completion in
                    vm?.setLoading(false)
                    
                    switch completion {
                    case .finished:
                        print("PlanCRUD, delete // Success : Plan 삭제 완료")
                    case .failure(let error):
                        vm?.handleError(error)
                        print("PlanCRUD, delete // Exception : Plan 삭제 실패 - \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak vm] _ in
                    vm?.removeCurrentSchedulePlan(planUID: planUID)
                    // [2026-05-27 Phase A.3] 서버 동기화 — schedule 전체 update (chat 보존).
                    if let schedule = vm?.selectedSchedule {
                        vm?.scheduleService.update(schedule)
                            .receive(on: DispatchQueue.main)
                            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
                            .store(in: &vm!.cancellables)
                    }
                    print("PlanCRUD, delete // Success : selectedSchedule에서 Plan 제거 완료")
                }
            )
            .store(in: &vm.cancellables)
    }

    func updateMemo(planUID: String, newMemo: String) {
        print("PlanCRUD, updateMemo // Info : Plan 메모 업데이트 - \(planUID)")
        guard let vm = vm else { return }
        
        vm.setLoading(true)
        
        vm.planService.updatePlanMemo(planUID: planUID, memo: newMemo)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak vm] completion in
                    vm?.setLoading(false)
                    
                    switch completion {
                    case .finished:
                        print("PlanCRUD, updateMemo // Success : Plan 메모 업데이트 완료")
                    case .failure(let error):
                        vm?.handleError(error)
                        print("PlanCRUD, updateMemo // Exception : Plan 메모 업데이트 실패 - \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak vm] updatedPlan in
                    vm?.updateUiSchedule(updatedPlan)
                    // [2026-05-27 Phase A.3] 서버 동기화 — chat 포함 incremental upsert.
                    if let schedule = vm?.selectedSchedule {
                        vm?.scheduleService.update(schedule)
                            .receive(on: DispatchQueue.main)
                            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
                            .store(in: &vm!.cancellables)
                    }
                    print("PlanCRUD, updateMemo // Success : selectedSchedule 메모 업데이트 완료")
                }
            )
            .store(in: &vm.cancellables)
    }

    func updateIndex(from source: Int, to destination: Int) {
        print("PlanCRUD, changeIndex // Info : Plan 순서 변경 - \(source) → \(destination)")
        guard let vm = vm else { return }
        
        // ✅ selectedSchedule?.planList 직접 사용
        let planList = vm.selectedSchedule?.planList ?? []
        
        guard source < planList.count && destination < planList.count else {
            print("PlanCRUD, changeIndex // Warning : 잘못된 인덱스")
            vm.handleError(PlanError.planNotFound)
            return
        }
        
        vm.setLoading(true)
        
        var tempList = planList
        let movedPlan = tempList.remove(at: source)
        tempList.insert(movedPlan, at: destination)
        let reorderedUIDs = tempList.map { $0.uid }

        // 낙관적 UI 업데이트: DB 응답 전에 즉시 반영
        if let schedule = vm.selectedSchedule {
            var reindexedList: [PlanModel] = []
            for (index, plan) in tempList.enumerated() {
                reindexedList.append(PlanModel(
                    uid: plan.uid,
                    index: index,
                    memo: plan.memo,
                    placeModel: plan.placeModel,
                    files: plan.files
                ))
            }
            // [2026-05-26] copy() — chatHistory 자동 preserve.
            vm.selectedSchedule = schedule.copy(
                editDate: schedule.editDate,
                planList: reindexedList
            )
        }

        vm.planService.reorderPlans(planUIDs: reorderedUIDs)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak vm] completion in
                    vm?.setLoading(false)
                    
                    switch completion {
                    case .finished:
                        print("PlanCRUD, changeIndex // Success : Plan 순서 변경 완료")
                    case .failure(let error):
                        vm?.handleError(error)
                        print("PlanCRUD, changeIndex // Exception : Plan 순서 변경 실패 - \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak vm] reorderedPlans in
                    guard let schedule = vm?.selectedSchedule else { return }

                    // [2026-05-26] copy() — chatHistory 자동 preserve.
                    let updated = schedule.copy(
                        editDate: schedule.editDate,
                        planList: reorderedPlans
                    )
                    vm?.selectedSchedule = updated
                    // [2026-05-27 Phase A.3] 서버 동기화 — reorder는 다른 기기에도 즉시 반영해야 함.
                    vm?.scheduleService.update(updated)
                        .receive(on: DispatchQueue.main)
                        .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
                        .store(in: &vm!.cancellables)
                    print("PlanCRUD, changeIndex // Success : selectedSchedule 순서 업데이트 완료")
                }
            )
            .store(in: &vm.cancellables)
    }
    
    private func extractFileData(from file: FileModel) -> Data? {
        if let data = file.data { return data }
        if !file.filePath.isEmpty {
            return FileCacheManager.shared.loadFile(fileModel: file)
        }
        return nil
    }
}

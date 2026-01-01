//
//  PlanCRUD.swift
//  HiRoute
//
//  Created by Jupond on 12/26/25.
//
import SwiftUI
import Combine

struct PlanCRUD {
    private weak var vm: PlanVM?
    
    init(vm: PlanVM) {
        self.vm = vm
    }
    
    func create(_ placeModel: PlaceModel, files: [FileModel] = []) {
        print("PlanCRUD, create // Info : Plan 생성 시작 - \(placeModel.title)")
        guard let vm = vm else { return }
        
        let newPlan = PlanModel(
            uid: "plan_\(UUID().uuidString)",
            index: vm.currentPlanList.count,
            memo: "",
            placeModel: placeModel,
            files: []
        )
        
        vm.setLoading(true)
        
        let fileList: [(Data, String, String)] = files.compactMap { file in
            guard let data = file.data else { return nil }
            return (data, file.fileName, file.fileType)
        }
        
        if !fileList.isEmpty {
            vm.setFileUploading(true)
        }
        
        let createPublisher: AnyPublisher<PlanModel, Error> = vm.planService.createPlan(newPlan, fileList: fileList)
        
        createPublisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak vm] completion in
                    vm?.setLoading(false)
                    vm?.setFileUploading(false)
                    vm?.updateFileUploadProgress(0.0)
                    
                    switch completion {
                    case .finished:
                        print("PlanCRUD, create // Success : Plan 생성 완료")
                        
                    case .failure(let error):
                        vm?.handleError(error)
                        print("PlanCRUD, create // Exception : Plan 생성 실패 - \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak vm] createdPlan in
                    vm?.currentPlanList.append(createdPlan)
                    vm?.currentPlan = createdPlan
                    vm?.updateSavedFilesFromPlan(createdPlan)
                    print("PlanCRUD, create // Success : Plan 로컬 업데이트 완료")
                }
            )
            .store(in: &vm.cancellables)
    }
    
    func read(uid: String) {
        print("PlanCRUD, read // Info : Plan 조회 - \(uid)")
        guard let vm = vm else { return }
        
        vm.setLoading(true)
        
        let readPublisher: AnyPublisher<PlanModel, Error> = vm.planService.readPlan(planUID: uid)
        
        readPublisher
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
                    vm?.currentPlan = plan
                    vm?.fileCRUD.readAll(planUID: plan.uid)
                }
            )
            .store(in: &vm.cancellables)
    }
    
    func readAll(scheduleUID: String) {
        print("PlanCRUD, readAll // Info : Plan 목록 조회 - \(scheduleUID)")
        guard let vm = vm else { return }
        
        vm.setLoading(true)
        
        let readListPublisher: AnyPublisher<[PlanModel], Error> = vm.planService.readPlanList(scheduleUID: scheduleUID)
        
        readListPublisher
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
                    vm?.currentPlanList = plans
                    print("PlanCRUD, readAll // Success : Plan 목록 로컬 업데이트 완료 - \(plans.count)개")
                }
            )
            .store(in: &vm.cancellables)
    }
    
    func update(_ plan: PlanModel) {
        print("PlanCRUD, update // Info : Plan 전체 업데이트 - \(plan.placeModel.title)")
        guard let vm = vm else { return }
        
        vm.setLoading(true)
        
        let updatePublisher: AnyPublisher<PlanModel, Error> = vm.planService.updatePlan(plan)
        
        updatePublisher
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
                    if let index = vm?.currentPlanList.firstIndex(where: { $0.uid == updatedPlan.uid }) {
                        vm?.currentPlanList[index] = updatedPlan
                    }
                    vm?.currentPlan = updatedPlan
                    print("PlanCRUD, update // Success : Plan 전체 업데이트 로컬 반영 완료")
                }
            )
            .store(in: &vm.cancellables)
    }
    
    func delete(planUID: String) {
        print("PlanCRUD, delete // Info : Plan 삭제 - \(planUID)")
        guard let vm = vm else { return }
        
        let backupPlanList = vm.currentPlanList
        let backupFiles = vm.files
        
        vm.setLoading(true)
        
        // 낙관적 업데이트: 로컬에서 먼저 제거
        vm.currentPlanList.removeAll { $0.uid == planUID }
        vm.files.removeAll { file in
            return file.filePath.contains(planUID)
        }
        
        let deletePublisher: AnyPublisher<Void, Error> = vm.planService.deletePlan(planUID: planUID)
        
        deletePublisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak vm] completion in
                    vm?.setLoading(false)
                    
                    switch completion {
                    case .finished:
                        print("PlanCRUD, delete // Success : Plan 삭제 완료")
                        
                    case .failure(let error):
                        // 실패시 백업 데이터로 롤백
                        vm?.currentPlanList = backupPlanList
                        vm?.files = backupFiles
                        vm?.handleError(error)
                        print("PlanCRUD, delete // Exception : Plan 삭제 실패, 롤백 - \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak vm] _ in
                    print("PlanCRUD, delete // Success : Plan 삭제 서버 동기화 완료")
                }
            )
            .store(in: &vm.cancellables)
    }
    
    func updateMemo(planUID: String, newMemo: String) {
        print("PlanCRUD, updateMemo // Info : Plan 메모 업데이트 - \(planUID)")
        guard let vm = vm else { return }
        
        vm.setLoading(true)
        
        let updateMemoPublisher: AnyPublisher<PlanModel, Error> = vm.planService.updatePlanMemo(planUID: planUID, memo: newMemo)
        
        updateMemoPublisher
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
                    if let index = vm?.currentPlanList.firstIndex(where: { $0.uid == planUID }) {
                        vm?.currentPlanList[index] = updatedPlan
                    }
                    vm?.currentPlan = updatedPlan
                    print("PlanCRUD, updateMemo // Success : Plan 메모 로컬 업데이트 완료")
                }
            )
            .store(in: &vm.cancellables)
    }
    
    func updateIndex(from source: Int, to destination: Int) {
        print("PlanCRUD, changeIndex // Info : Plan 순서 변경 - \(source) → \(destination)")
        guard let vm = vm else { return }
        
        guard source < vm.currentPlanList.count && destination < vm.currentPlanList.count else {
            print("PlanCRUD, changeIndex // Warning : 잘못된 인덱스")
            vm.handleError(PlanError.planNotFound)
            return
        }
        
        let backupPlanList = vm.currentPlanList
        
        vm.setLoading(true)
        
        // 낙관적 업데이트: 로컬에서 먼저 순서 변경
        let movedPlan = vm.currentPlanList.remove(at: source)
        vm.currentPlanList.insert(movedPlan, at: destination)
        
        let reorderedUIDs: [String] = vm.currentPlanList.map { $0.uid }
        
        let reorderPublisher: AnyPublisher<[PlanModel], Error> = vm.planService.reorderPlans(planUIDs: reorderedUIDs)
        
        reorderPublisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak vm] completion in
                    vm?.setLoading(false)
                    
                    switch completion {
                    case .finished:
                        print("PlanCRUD, changeIndex // Success : Plan 순서 변경 완료")
                        
                    case .failure(let error):
                        // 실패시 백업 데이터로 롤백
                        vm?.currentPlanList = backupPlanList
                        vm?.handleError(error)
                        print("PlanCRUD, changeIndex // Exception : Plan 순서 변경 실패, 롤백 - \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak vm] reorderedPlans in
                    vm?.currentPlanList = reorderedPlans
                    print("PlanCRUD, changeIndex // Success : Plan 순서 변경 서버 동기화 완료")
                }
            )
            .store(in: &vm.cancellables)
    }
}

//
//  LogManager.swift
//  HiRoute
//
//  Created by Jupond on 12/21/25.
//
import Foundation
/**
 * 모든 Schedule 관련 바인딩을 한 곳에 모은 컨테이너
 * - 중복 코드 제거
 * - 일관성 있는 바인딩 관리
 * - 확장성 고려
 * - ScheduleVM의 편집 상태와 연동
 * - 메모리 안전 보장 (weak capture)
 */

struct ScheduleCRUD {
    private weak var vm: ScheduleVM?
    
    init(vm: ScheduleVM) {
        self.vm = vm
    }
    
    func create(title: String, memo: String, dDay: Date, planList : [PlanModel], result: @escaping (Bool) -> Void) {
        print("ScheduleCRUD, create // 일정 생성 시작 - \(title)")
        guard let vm = vm else { return  }

        // UI 모델 생성
        let scheduleModel = ScheduleModel(
            uid: "schedule_\(UUID().uuidString)",
            index: vm.schedules.count,
            title: title,
            memo: memo,
            editDate: Date(),
            d_day: dDay,
            planList: planList
        )
        
        // UI 상태 업데이트
        vm.setLoading(true)
        
        // Service 호출
        vm.scheduleService.create(scheduleModel)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated)) // 백그라운드에서 데이터 처리(백그라운드에서 무거운 작업)
            .receive(on: DispatchQueue.main) // 메인 스레드에서 UI 업데이트
            .sink(
                receiveCompletion: { [weak vm] completion in
                    // 로딩 종료
                    vm?.setLoading(false)
                                       
                    
                    /*
                     - 스트림이 완료되거나 에러 발생시 호출
                     - .finished 또는 .failure(Error)
                    */
                    switch completion {
                    case .finished:
                        /*
                         코드가 한번 돌면 스트림의 생명주기가 끝남 (한 번만 호출됨)
                         */
                        // 메인 스레드 보장
                        DispatchQueue.main.async {
                            result(true)
                        }
                        print("ScheduleCRUD, create // Success : 스트림 정상 완료")
                        
                    case .failure(let error):
                        // 에러 처리
                        vm?.handleError(error)
                        
                        // 메인 스레드 보장
                        DispatchQueue.main.async {
                            result(false)
                        }

                        // 실패시 롤백 및 에러 처리
                        print("ScheduleCRUD, create // Exception : 서버 동기화 실패, 로컬 롤백 - \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak vm] createdScheduleModel in
                    // 서버 성공 후에만 UI에 추가, 메인 스레드에서 @Published 업데이트
                    vm?.schedules.append(createdScheduleModel) 
                    print("ScheduleCRUD, create // Success : 서버 확인 후 안전하게 추가 완료")
                }
            )
            .store(in: &vm.cancellables)
    }
    
    /**
     * 일정 삭제 (오프라인 자동 감지)
     * case 온라인 :
     *  1. API 호출하여 서버 DB에서 삭제
     *  2. 로컬 DB에 해당 Schedule모델 삭제
     *  3. UI에서 즉시 제거
     * case 오프라인 :
     *  1. CustomQueueManager에 해당 schedule모델을 인터넷연결시 API 호출하여 서버 DB에서도 삭제
     *  2. 로컬 DB에 해당 Schedule모델 삭제
     *  3. UI에서 즉시 제거
     *  삭제 실패시 :
     *  1. 삭제 시도 취소
     *  2. 삭제하려 했던 Schedule 모델 복구
     *  3. UI 복구
     *  4. 에러 메세지 호출
     */
    func delete(scheduleUID: String) {
        guard let vm = vm else { return }
        
        
        // 삭제할 데이터가 존재하는지 확인
        guard let targetSchedule = vm.schedules.first(where: { $0.uid == scheduleUID }),
              let scheduleIndex = vm.schedules.firstIndex(where: { $0.uid == scheduleUID }) else {
            print("ScheduleCRUD, delete // Warning : 삭제할 일정을 찾을 수 없음")
            vm.handleError(ScheduleError.notFound)
            return
        }
        
        // 로딩 시작 - 사용자에게 "삭제 중..." 표시
        vm.setLoading(true)
        
        //  서버 삭제 요청, Service에서 네트워크 상태 자동 판단
        vm.scheduleService.delete(uid: targetSchedule.uid)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak vm] completion in
                    // 로딩 종료
                    vm?.setLoading(false)
                    
                    switch completion {
                    case .finished:
                        print("ScheduleCRUD, delete // Success : 서버 삭제 성공 확인")
                        
                    case .failure(let error):
                        // 실패시 UI는 그대로 두고 에러만 표시
                        vm?.handleError(error)
                        print("ScheduleCRUD, delete // Exception : 서버 삭제 실패, UI 변경 없음 - \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak vm] _ in // Void이므로 _ 사용이 정답
                    // 서버에서 성공 신호 받음 → 요청한 scheduleUID 삭제 성공
                    guard let vm = vm else { return }
                    
                    // 안전하게 UI에서 제거
                    vm.schedules.removeAll { $0.uid == scheduleUID }

                    if vm.selectedSchedule?.uid == scheduleUID {
                        vm.selectedSchedule = nil
                    }
                    
                    print("ScheduleCRUD, delete // Success : 서버 확인 후 안전하게 제거 완료 - \(scheduleUID)")
                }
            )
            .store(in: &vm.cancellables)
    }
    
    func readAll(page: Int = 0, itemsPerPage: Int = 10) {
        print("ScheduleCRUD, readAll // Info : 서버 일정 목록 로드 시작 - page:\(page)")
        guard let vm = vm else { return }
        
        // 로딩 시작
        vm.setLoading(true)
        
        // Service 호출
        vm.scheduleService.readAll(page: page, itemsPerPage: itemsPerPage)
            .receive(on: DispatchQueue.main) // 메인 스레드에서 결과 처리
            .sink(
                receiveCompletion: { [weak vm] completion in
                    // 로딩 종료
                    vm?.setLoading(false)
                    
                    switch completion {
                    case .finished:
                        print("ScheduleCRUD, readAll // Success : 서버 목록 로드 완료")
                        
                    case .failure(let error):
                        // 실패시 에러 처리
                        vm?.handleError(error)
                        print("ScheduleCRUD, readAll // Exception : 서버 목록 로드 실패 - \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak vm] serverSchedules in
                    // 서버에서 받은 데이터로 UI 업데이트
                    vm?.schedules = serverSchedules
                    print("ScheduleCRUD, readAll // Success : 서버 동기화 완료 - \(serverSchedules.count)개")
                }
            )
            .store(in: &vm.cancellables)
    }
    
    func read(uid: String) {
        print("ScheduleCRUD, readOne // Info : 특정 일정 로드 시작 - \(uid)")
        guard let vm = vm else { return }
        
        // 로딩 시작
        vm.setLoading(true)
        
        vm.scheduleService.read(uid: uid)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak vm] completion in
                    // 로딩 종료
                    vm?.setLoading(false)
                    
                    switch completion {
                    case .finished:
                        print("ScheduleCRUD, readOne // Success : 특정 일정 로드 완료")
                        
                    case .failure(let error):
                        // 실패시 에러 처리
                        vm?.handleError(error)
                        print("ScheduleCRUD, readOne // Exception : 특정 일정 로드 실패 - \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak vm] schedule in
                    // 서버에서 받은 데이터로 UI 업데이트
                    guard let vm = vm else { return }
                    
                    // 선택된 일정 업데이트
                    vm.selectedSchedule = schedule
                    
                    // 목록에서도 해당 일정 업데이트
                    if let index = vm.schedules.firstIndex(where: { $0.uid == uid }) {
                        vm.schedules[index] = schedule
                    }
                    
                    print("ScheduleCRUD, readOne // Success : 일정 로드 완료 - \(schedule.title)")
                }
            )
            .store(in: &vm.cancellables)
    }
    
    func update(_ updatedSchedule: ScheduleModel, completion: @escaping (Bool) -> Void = { _ in }) {
        print("ScheduleCRUD, update // Info : 일정 업데이트 시작 - \(updatedSchedule.title)")
        guard let vm = vm else { return }
        
        // 업데이트할 원본 데이터 확인
        guard let originalSchedule = vm.schedules.first(where: { $0.uid == updatedSchedule.uid }) else {
            print("ScheduleCRUD, update // Warning : 업데이트할 일정을 찾을 수 없음")
            vm.handleError(ScheduleError.notFound)
            return
        }
        
        // 로딩 시작
        vm.setLoading(true)
        
        vm.scheduleService.update(updatedSchedule)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak vm] completion in
                    // 로딩 종료
                    vm?.setLoading(false)
                    
                    switch completion {
                    case .finished:
                        print("ScheduleCRUD, update // Success : 서버 업데이트 완료")
                        
                    case .failure(let error):
                        // 실패시 에러 처리 (UI는 원본 그대로 유지)
                        vm?.handleError(error)
                        print("ScheduleCRUD, update // Exception : 서버 업데이트 실패, 원본 유지 - \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak vm] serverSchedule in
                    // 서버 업데이트 성공 후 UI 반영
                    guard let vm = vm else { return }
                    
                    // 목록에서 업데이트
                    if let index = vm.schedules.firstIndex(where: { $0.uid == serverSchedule.uid }) {
                        vm.schedules[index] = serverSchedule
                    }
                    
//                    // 선택된 일정 업데이트
//                    vm.selectedSchedule = serverSchedule
                    
                    completion(true)
                    print("ScheduleCRUD, update // Success : 서버 확인 후 안전하게 업데이트 완료")
                }
            )
            .store(in: &vm.cancellables)
    }
       
    func updateScheduleInfo(uid: String, title: String, memo: String, dDay: Date, completion: @escaping (Bool) -> Void = { _ in }) {
        guard let vm = vm else { return }
        
        vm.scheduleService.updateScheduleInfo(uid: uid, title: title, memo: memo, dDay: dDay)
            .receive(on: DispatchQueue.main)  // ✅ 메인 스레드 강제
            .sink(
                receiveCompletion: { [weak vm] completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        vm?.handleError(error)
                        print("ScheduleCRUD, updateScheduleInfo // Exception : \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak vm] updatedSchedule in
                    guard let vm = vm else { return }
                    
                    // ✅ 메인 스레드에서 안전하게 UI 업데이트
                    if let index = vm.schedules.firstIndex(where: { $0.uid == updatedSchedule.uid }) {
                        vm.schedules[index] = updatedSchedule
                    }
                    
                    completion(true)
                    print("ScheduleCRUD, updateScheduleInfo // Success : DB 우선 업데이트 완료")
                }
            )
            .store(in: &vm.cancellables)
    }
    func refreshScheduleList(){
        
    }
}

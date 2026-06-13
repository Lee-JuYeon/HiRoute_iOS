//
//  ScheduleRepository.swift
//  HiRoute
//
//  Created by Jupond on 7/26/25.
//
import Combine
import Foundation
import CoreData

/*
 MVVM + Service Layer에서의 respotiroy의 역할
 - 캐시 관리
 - 로컬 저장소 관리
 - 서버 통신 시뮬레이션
 - CRUD 오퍼레이션
 */

class ScheduleRepository: ScheduleProtocol {
    private let localDB = LocalDB.shared
    private let networkMonitor = NetworkMonitor()
    /// [2026-05-27 Phase A.1] fire-and-forget 서버 chat append용. 메모리에서 자동 정리.
    fileprivate var chatAppendCancellables = Set<AnyCancellable>()

    init() {
        print("ScheduleRepository, init // Success : Repository 초기화 완료")
    }
    
    // MARK: - CRUD Operations
    
    func create(_ scheduleModel: ScheduleModel) -> AnyPublisher<ScheduleModel, Error> {
        return Future<ScheduleModel, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(ScheduleError.unknown))
                return
            }
            
            // 중복 체크 (비동기)
            self.localDB.readSchedule(scheduleUID: scheduleModel.uid) { existingSchedule in
                if existingSchedule != nil {
                    promise(.failure(ScheduleError.duplicateSchedule))
                    print("ScheduleRepository, create // Warning : 중복된 일정 - \(scheduleModel.uid)")
                    return
                }
                
                // 데이터 저장 (비동기)
                self.localDB.createSchedule(scheduleModel) { success in
                    if success {
                        promise(.success(scheduleModel))
                    } else {
                        promise(.failure(ScheduleError.saveFailed))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func read(scheduleUID: String) -> AnyPublisher<ScheduleModel, Error> {
        return Future<ScheduleModel, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(ScheduleError.unknown))
                return
            }
            
            self.localDB.readSchedule(scheduleUID: scheduleUID) { schedule in
                if let schedule = schedule {
                    promise(.success(schedule))
                    print("ScheduleRepository, read // Success : 일정 조회 완료 - \(scheduleUID)")
                } else {
                    promise(.failure(ScheduleError.notFound))
                    print("ScheduleRepository, read // Warning : 일정을 찾을 수 없음 - \(scheduleUID)")
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    ///  페이지네이션이 적용된 목록 조회
    func readAll(page: Int, itemsPerPage: Int) -> AnyPublisher<[ScheduleModel], Error> {
        return Future<[ScheduleModel], Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(ScheduleError.unknown))
                return
            }
            
            // 전체 데이터 조회 (비동기)
            self.localDB.readAllSchedules { allSchedules in
                
                // 페이지네이션 계산
                let startIndex = page * itemsPerPage
                let endIndex = min(startIndex + itemsPerPage, allSchedules.count)
                
                // 범위 검증
                guard startIndex < allSchedules.count else {
                    promise(.success([])) // 빈 배열 (범위 초과)
                    print("ScheduleRepository, readAll // Warning : 페이지 범위 초과 - page:\(page)")
                    return
                }
                
                // 페이지 데이터 추출
                let pageSchedules = Array(allSchedules[startIndex..<endIndex])
                promise(.success(pageSchedules)) // 페이지 데이터
                print("ScheduleRepository, readAll // Success : 페이지 조회 완료 - page:\(page), count:\(pageSchedules.count)")
            }
        }
        .eraseToAnyPublisher()
    }
    
    func update(_ scheduleModel: ScheduleModel) -> AnyPublisher<ScheduleModel, Error> {
        return Future<ScheduleModel, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(ScheduleError.unknown))
                return
            }
            
            // 존재 여부 확인 (비동기)
            self.localDB.readSchedule(scheduleUID: scheduleModel.uid) { existingSchedule in
                guard existingSchedule != nil else {
                    promise(.failure(ScheduleError.notFound))
                    print("ScheduleRepository, update // Warning : 업데이트할 일정을 찾을 수 없음 - \(scheduleModel.uid)")
                    return
                }
                
                // 업데이트 (비동기)
                self.localDB.updateSchedule(scheduleModel) { success in
                    if success {
                        promise(.success(scheduleModel))
                        print("ScheduleRepository, update // Success : 일정 업데이트 완료 - \(scheduleModel.title)")
                    } else {
                        promise(.failure(ScheduleError.updateFailed))
                        print("ScheduleRepository, update // Exception : 일정 업데이트 실패")
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
        
    /// [2026-05-26 Phase 2] 메타 필드만 업데이트 — chatHistory/planList 안 건드림.
    func updateMeta(scheduleUID: String, title: String, memo: String, dDay: Date, editDate: Date) -> AnyPublisher<ScheduleModel, Error> {
        return Future<ScheduleModel, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(ScheduleError.unknown))
                return
            }

            self.localDB.readSchedule(scheduleUID: scheduleUID) { existingSchedule in
                guard let existing = existingSchedule else {
                    promise(.failure(ScheduleError.notFound))
                    print("ScheduleRepository, updateMeta // Warning : Schedule을 찾을 수 없음 - \(scheduleUID)")
                    return
                }

                self.localDB.updateScheduleMeta(scheduleUID: scheduleUID, title: title, memo: memo, dDay: dDay, editDate: editDate) { success in
                    if success {
                        // 갱신된 메타 반영한 새 모델 (chatHistory/planList는 기존 보존)
                        let updated = existing.copy(title: title, memo: memo, editDate: editDate, d_day: dDay)
                        promise(.success(updated))
                        print("ScheduleRepository, updateMeta // Success : 메타 업데이트 완료 - \(title)")
                    } else {
                        promise(.failure(ScheduleError.updateFailed))
                        print("ScheduleRepository, updateMeta // Exception : 메타 업데이트 실패")
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func delete(scheduleUID: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(ScheduleError.unknown))
                return
            }
            
            // 존재 여부 확인 (비동기)
            self.localDB.readSchedule(scheduleUID: scheduleUID) { existingSchedule in
                guard existingSchedule != nil else {
                    promise(.failure(ScheduleError.notFound))
                    print("ScheduleRepository, delete // Warning : 삭제할 일정을 찾을 수 없음 - \(scheduleUID)")
                    return
                }
                
                // 삭제 (비동기)
                self.localDB.deleteSchedule(scheduleUID: scheduleUID) { success in
                    if success {
                        promise(.success(()))
                        print("ScheduleRepository, delete // Success : 일정 삭제 완료 - \(scheduleUID)")
                    } else {
                        promise(.failure(ScheduleError.updateFailed))
                        print("ScheduleRepository, delete // Exception : 일정 삭제 실패")
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
        
    func reorderSchedules(scheduleUIDs: [String]) -> AnyPublisher<[ScheduleModel], Error> {
        return Future<[ScheduleModel], Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(ScheduleError.unknown))
                return
            }

            // 모든 Schedule 존재 확인 (순차적 비동기 체크)
            self.validateAllSchedulesExist(scheduleUIDs: scheduleUIDs) { allExist in
                guard allExist else {
                    promise(.failure(ScheduleError.notFound))
                    print("ScheduleRepository, reorderSchedules // Warning : 일부 Schedule을 찾을 수 없음")
                    return
                }

                // 순서 업데이트 (순차적 비동기 처리)
                self.updateScheduleIndices(scheduleUIDs: scheduleUIDs) { updatedSchedules in
                    if let updatedSchedules = updatedSchedules {
                        promise(.success(updatedSchedules))
                        print("ScheduleRepository, reorderSchedules // Success : Schedule 순서 변경 완료 - \(scheduleUIDs.count)개")
                    } else {
                        promise(.failure(ScheduleError.reorderFailed))
                        print("ScheduleRepository, reorderSchedules // Exception : Schedule 순서 변경 실패")
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /// [2026-05-27 Phase A.1] 채팅 메시지 1건 — 로컬 즉시 저장 + 서버 비동기 동기화.
    /// WHY: 어제 chatHistory wipe 사고 영구 손실 — chatHistory가 서버에 한 번도 안 갔던 게 원인.
    /// 이제 매 메시지마다 `POST /api/schedules/:uid/chat` 호출 (idempotent).
    /// 서버 호출 실패해도 로컬은 살아있고, 다음 schedule sync 때 chatHistory 배열로 동기화됨.
    func appendChatMessage(scheduleUID: String, message: ChatMessageModel) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(ScheduleError.unknown))
                return
            }
            self.localDB.appendChatMessageToSchedule(scheduleUID: scheduleUID, message: message) { success in
                if !success {
                    promise(.failure(ScheduleError.updateFailed))
                    return
                }
                // 로컬 저장 성공 — 즉시 promise 완료. 서버 동기화는 fire-and-forget.
                promise(.success(()))
                self.appendChatMessageToServer(scheduleUID: scheduleUID, message: message)
            }
        }
        .eraseToAnyPublisher()
    }

    /// [2026-05-27 Phase A.1] 서버 chat append — fire-and-forget.
    /// 실패해도 로컬은 보존되며 다음 schedule sync 때 catch up.
    private func appendChatMessageToServer(scheduleUID: String, message: ChatMessageModel) {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let body = ChatMessageRequest(
            uid: message.uid,
            role: message.role.rawValue,
            content: message.content,
            attachedPlacesJson: ChatMessageResponseHelper.encodePlaces(message.attachedPlaces),
            createdAt: formatter.string(from: message.createdAt),
            deletedAt: nil
        )
        let publisher: AnyPublisher<APIResponse<ChatMessageResponse>, Error> =
            APIClient.shared.postWithAuth(path: "/api/schedules/\(scheduleUID)/chat", body: body)

        publisher
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        #if DEBUG
                        print("ScheduleRepository, appendChatMessageToServer // 서버 sync 실패 (로컬은 OK): \(error.localizedDescription)")
                        #endif
                    }
                },
                receiveValue: { _ in
                    #if DEBUG
                    print("ScheduleRepository, appendChatMessageToServer // 서버 sync 성공 - \(message.uid)")
                    #endif
                }
            )
            .store(in: &chatAppendCancellables)
    }

    // MARK: - Reorder Helper Methods

    private func validateAllSchedulesExist(scheduleUIDs: [String], completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        var allExist = true

        for scheduleUID in scheduleUIDs {
            group.enter()
            localDB.readSchedule(scheduleUID: scheduleUID) { schedule in
                if schedule == nil {
                    allExist = false
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(allExist)
        }
    }

    private func updateScheduleIndices(scheduleUIDs: [String], completion: @escaping ([ScheduleModel]?) -> Void) {
        var updatedSchedules: [ScheduleModel] = []
        let group = DispatchGroup()
        var hasError = false

        for (newIndex, scheduleUID) in scheduleUIDs.enumerated() {
            group.enter()
            localDB.updateScheduleIndex(scheduleUID: scheduleUID, newIndex: newIndex) { success in
                if success {
                    self.localDB.readSchedule(scheduleUID: scheduleUID) { schedule in
                        if let schedule = schedule {
                            updatedSchedules.append(schedule)
                        } else {
                            hasError = true
                        }
                        group.leave()
                    }
                } else {
                    hasError = true
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            completion(hasError ? nil : updatedSchedules.sorted { $0.index < $1.index })
        }
    }

    /// 중복 장소 체크 (비즈니스 룰)
    private func checkDuplicatePlace(placeUid: String, in scheduleModel: ScheduleModel) -> Result<Void, ScheduleError> {
        if scheduleModel.planList.contains(where: { $0.placeModel.uid == placeUid }) {
            print("ScheduleRepository, checkDuplicatePlace // Warning : 중복 장소 추가 시도 - \(placeUid)")
            return .failure(.duplicatePlace)
        }
        return .success(())
    }
    
    ///  현재 일정 존재 여부 체크
    private func checkCurrentScheduleExists() -> AnyPublisher<ScheduleModel, Error> {
        return Future<ScheduleModel, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(ScheduleError.unknown))
                return
            }
            
            // 비동기 호출
            self.localDB.readAllSchedules { allSchedules in
                // 가장 최근 편집된 일정을 현재 일정으로 간주
                guard let currentSchedule = allSchedules.first else {
                    print("ScheduleRepository, checkCurrentScheduleExists // Warning : 현재 스케줄이 없음")
                    promise(.failure(ScheduleError.noCurrentSchedule))
                    return
                }
                
                promise(.success(currentSchedule))
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// 네트워크 상태 확인
    private func checkNetworkAndSync() -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(ScheduleError.unknown))
                return
            }
            
            let isConnected = self.networkMonitor.isConnected
            
            if !isConnected {
                promise(.failure(ScheduleError.networkError))
                print("ScheduleRepository, checkNetworkAndSync // Warning : 네트워크 연결 끊어짐")
            } else {
                promise(.success(true))
                print("ScheduleRepository, checkNetworkAndSync // Success : 네트워크 연결 정상")
            }
        }
        .eraseToAnyPublisher()
    }
    
    ///  페이지네이션 정보 계산
    private func getPaginationInfo(page: Int, itemsPerPage: Int) -> AnyPublisher<PaginationInfo, Error> {
        return Future<PaginationInfo, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(ScheduleError.unknown))
                return
            }
            
            // 비동기 호출
            self.localDB.readAllSchedules { allSchedules in
                let totalCount = allSchedules.count
                let totalPages = (totalCount + itemsPerPage - 1) / itemsPerPage // 올림 계산
                let hasNextPage = page < totalPages - 1
                let hasPreviousPage = page > 0
                
                let info = PaginationInfo(
                    currentPage: page,
                    itemsPerPage: itemsPerPage,
                    totalItems: totalCount,
                    totalPages: totalPages,
                    hasNextPage: hasNextPage,
                    hasPreviousPage: hasPreviousPage
                )
                
                promise(.success(info))
                print("ScheduleRepository, getPaginationInfo // Success : 페이지 정보 - \(page+1)/\(totalPages)")
            }
        }
        .eraseToAnyPublisher()
    }
    
    deinit {
        print("ScheduleRepository, deinit // Success : Repository 해제 완료")
    }
}


//
//  ScheduleUpdateManager.swift
//  HiRoute
//
//  Created by Jupond on 12/5/25.
//
import Foundation
import Combine

/**
 * VisitPlaceService
 * - VisitPlace 도메인의 비즈니스 로직 담당
 * - Schedule과 Place를 연결하는 중간 역할
 * - 방문장소의 순서 관리 및 메모 관리
 */
class VisitPlaceService {
    
    // MARK: - Dependencies
    private let repository: VisitPlaceProtocol
    
    // MARK: - Reactive
    private var cancellables = Set<AnyCancellable>()
    
    /**
     * 초기화
     * @param repository: VisitPlace 데이터 액세스 담당 Repository
     */
    init(repository: VisitPlaceProtocol) {
        self.repository = repository
        print("VisitPlaceService, init // Success : Repository 연결 완료")
    }
    
    // MARK: - Standard CRUD Operations
    
    /**
     * 새 방문장소 생성
     * - Schedule에 Place를 추가할 때 사용
     * - index는 현재 Schedule의 마지막 순서 + 1로 자동 설정 권장
     * @param visitPlace: 생성할 방문장소 모델
     * @return: 생성된 방문장소 Publisher
     */
    func create(_ visitPlace: VisitPlaceModel) -> AnyPublisher<VisitPlaceModel, Error> {
        print("VisitPlaceService, create // Info : 방문장소 생성 시작 - \(visitPlace.uid)")
        
        return repository.create(visitPlace)
            .handleEvents(
                receiveOutput: { visitPlace in
                    print("VisitPlaceService, create // Success : 방문장소 생성 완료 - \(visitPlace.placeModel.title)")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("VisitPlaceService, create // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    /**
     * 특정 방문장소 조회
     * - UID로 단일 방문장소 조회
     * - Place 정보와 첨부 File들도 함께 반환
     * @param uid: 조회할 방문장소 UID
     * @return: 조회된 방문장소 Publisher
     */
    func read(uid: String) -> AnyPublisher<VisitPlaceModel, Error> {
        print("VisitPlaceService, read // Info : 방문장소 조회 시작 - \(uid)")
        
        return repository.read(uid: uid)
            .handleEvents(
                receiveOutput: { visitPlace in
                    print("VisitPlaceService, read // Success : 방문장소 조회 완료 - \(visitPlace.placeModel.title)")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("VisitPlaceService, read // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    /**
     * 특정 일정의 모든 방문장소 조회
     * - Schedule에 속한 방문장소들을 방문 순서(index)대로 정렬하여 반환
     * - 여행 일정 상세보기에서 사용
     * @param scheduleUID: 일정 UID
     * @return: 정렬된 방문장소 목록 Publisher
     */
    func readAll(scheduleUID: String) -> AnyPublisher<[VisitPlaceModel], Error> {
        print("VisitPlaceService, readAll // Info : 일정 방문장소 조회 - \(scheduleUID)")
        
        return repository.readAll(scheduleUID: scheduleUID)
            .map { visitPlaces in
                // 추가 비즈니스 로직: index 순서 보장 + 검증
                return visitPlaces.sorted { $0.index < $1.index }
            }
            .handleEvents(
                receiveOutput: { visitPlaces in
                    print("VisitPlaceService, readAll // Success : 방문장소 목록 조회 완료 - \(visitPlaces.count)개")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("VisitPlaceService, readAll // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    /**
     * 방문장소 정보 수정
     * - memo, index, 첨부 파일 등 VisitPlace 속성 수정
     * - Place 기본 정보 변경은 PlaceService에서 처리
     * @param visitPlace: 수정된 방문장소 모델
     * @return: 수정된 방문장소 Publisher
     */
    func update(_ visitPlace: VisitPlaceModel) -> AnyPublisher<VisitPlaceModel, Error> {
        print("VisitPlaceService, update // Info : 방문장소 업데이트 시작 - \(visitPlace.uid)")
        
        return repository.update(visitPlace)
            .handleEvents(
                receiveOutput: { visitPlace in
                    print("VisitPlaceService, update // Success : 방문장소 업데이트 완료 - \(visitPlace.placeModel.title)")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("VisitPlaceService, update // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    /**
     * 방문장소 삭제
     * - Schedule에서 Place 제거
     * - 연결된 첨부 파일들도 함께 삭제됨
     * - Place 자체는 삭제되지 않음 (다른 Schedule에서 사용 가능)
     * @param uid: 삭제할 방문장소 UID
     * @return: 삭제 완료 Publisher
     */
    func delete(uid: String) -> AnyPublisher<Void, Error> {
        print("VisitPlaceService, delete // Info : 방문장소 삭제 시작 - \(uid)")
        
        return repository.delete(uid: uid)
            .handleEvents(
                receiveOutput: { _ in
                    print("VisitPlaceService, delete // Success : 방문장소 삭제 완료 - \(uid)")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("VisitPlaceService, delete // Exception : \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
    
    // MARK: - VisitPlace Domain Business Logic
    
    /**
     * 방문장소 메모 업데이트
     * - 특정 방문장소의 개인 메모만 수정하는 편의 메서드
     * - 여행 중 개인적인 메모나 후기 작성할 때 사용
     * @param uid: 수정할 방문장소 UID
     * @param memo: 새 메모 내용
     * @return: 수정된 방문장소 Publisher
     */
    func updateMemo(uid: String, memo: String) -> AnyPublisher<VisitPlaceModel, Error> {
        print("VisitPlaceService, updateMemo // Info : 방문장소 메모 업데이트 - \(uid)")
        
        return read(uid: uid)
            .map { visitPlace in
                // Immutable 패턴으로 새 모델 생성
                return VisitPlaceModel(
                    uid: visitPlace.uid,
                    index: visitPlace.index,
                    memo: memo, // 메모만 변경
                    placeModel: visitPlace.placeModel, // 기존 Place 정보 유지
                    files: visitPlace.files // 기존 파일들 유지
                )
            }
            .flatMap { [weak self] updatedVisitPlace in
                guard let self = self else {
                    return Fail<VisitPlaceModel, Error>(error: ScheduleError.unknown)
                        .eraseToAnyPublisher()
                }
                return self.update(updatedVisitPlace)
            }
            .eraseToAnyPublisher()
    }
    
    /**
     * 방문장소 순서 변경
     * - 특정 방문장소의 index만 변경하는 편의 메서드
     * - 드래그앤드롭으로 순서 변경할 때 사용
     * @param uid: 수정할 방문장소 UID
     * @param newIndex: 새로운 방문 순서
     * @return: 수정된 방문장소 Publisher
     */
    func updateIndex(uid: String, newIndex: Int) -> AnyPublisher<VisitPlaceModel, Error> {
        print("VisitPlaceService, updateIndex // Info : 방문장소 순서 변경 - \(uid) to \(newIndex)")
        
        return read(uid: uid)
            .map { visitPlace in
                // Immutable 패턴으로 새 모델 생성
                return VisitPlaceModel(
                    uid: visitPlace.uid,
                    index: newIndex, // 순서만 변경
                    memo: visitPlace.memo, // 기존 메모 유지
                    placeModel: visitPlace.placeModel, // 기존 Place 정보 유지
                    files: visitPlace.files // 기존 파일들 유지
                )
            }
            .flatMap { [weak self] updatedVisitPlace in
                guard let self = self else {
                    return Fail<VisitPlaceModel, Error>(error: ScheduleError.unknown)
                        .eraseToAnyPublisher()
                }
                return self.update(updatedVisitPlace)
            }
            .eraseToAnyPublisher()
    }
    
    /**
     * 다중 방문장소 순서 재정렬
     * - UI에서 드래그앤드롭으로 여러 장소의 순서를 한번에 변경할 때 사용
     * - 각 VisitPlace의 index를 배열 순서에 맞게 업데이트
     * @param uids: 새로운 순서로 정렬된 VisitPlace UID 배열
     * @return: 재정렬된 방문장소 목록 Publisher
     */
    func reorder(uids: [String]) -> AnyPublisher<[VisitPlaceModel], Error> {
        print("VisitPlaceService, reorder // Info : 방문장소 순서 재정렬 - \(uids.count)개")
        
        // 각 UID에 대해 새로운 index로 업데이트
        let updatePublishers = uids.enumerated().map { (newIndex, uid) in
            updateIndex(uid: uid, newIndex: newIndex)
        }
        
        // 모든 업데이트를 병렬 실행 후 결과 수집
        return Publishers.MergeMany(updatePublishers)
            .collect()
            .map { visitPlaces in
                // 최종적으로 index 순서로 정렬하여 반환
                return visitPlaces.sorted { $0.index < $1.index }
            }
            .eraseToAnyPublisher()
    }
    
    deinit {
        cancellables.removeAll()
        print("VisitPlaceService, deinit // Success : VisitPlace 서비스 해제 완료")
    }
}

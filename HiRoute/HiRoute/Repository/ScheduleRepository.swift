//
//  RouteRepositoryProtocol.swift
//  HiRoute
//
//  Created by Jupond on 7/26/25.
//
import Combine
import Foundation

/*
 MVVM + Service Layer에서의 respotiroy의 역할
 - 캐시 관리
 - 로컬 저장소 관리
 - 서버 통신 시뮬레이션
 - CRUD 오퍼레이션
 */

class ScheduleRepository: ScheduleProtocol {
    
    // 로컬 저장소 (DummyPack 대신)
    private var localSchedules: [ScheduleModel] = []
    
    // 메모리 캐시 - 최대 100개 항목만 유지
    private var cache = NSCache<NSString, AnyObject>()
    private let cacheQueue = DispatchQueue(label: "com.schedule.cache", qos: .utility)
    init() {
        setupCache()
        loadInitialData()
    }
    
    private func setupCache() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }
    
    private func loadInitialData() {
        // 초기 더미 데이터 로드
        localSchedules = DummyPack.sampleSchedules
    }
    
    func createSchedule(_ scheduleModel: ScheduleModel) -> AnyPublisher<ScheduleModel, Error> {
        Future<ScheduleModel, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(ScheduleError.unknown))
                return
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                // 실제 서버 통신 시뮬레이션
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.localSchedules.append(scheduleModel)
                    
                    // 캐시 무효화 (새 데이터 추가되었으니)
                    self.invalidateCache()

                    promise(.success(scheduleModel))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func readSchedule(scheduleModelUID: String) -> AnyPublisher<ScheduleModel, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(ScheduleError.unknown))
                return
            }
            
            let cacheKey = "schedule_\(scheduleModelUID)" as NSString
            
            // 1. 캐시에서 먼저 확인
            self.cacheQueue.async {
                if let cachedSchedule = self.cache.object(forKey: cacheKey) as? ScheduleModel {
                    DispatchQueue.main.async {
                        promise(.success(cachedSchedule))
                    }
                    return
                }
                
                // 2. 로컬에서 확인
                if let schedule = self.localSchedules.first(where: { $0.uid == scheduleModelUID }) {
                    // 캐시에 저장
                    self.cache.setObject(schedule as AnyObject, forKey: cacheKey)
                    
                    DispatchQueue.main.async {
                        promise(.success(schedule))
                    }
                    return
                }
                
                // 3. 서버에서 가져오기 (마지막 수단)
                DispatchQueue.global(qos: .background).async {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        // 서버에서 못 찾은 경우
                        promise(.failure(ScheduleError.notFound))
                        
                        // 또는 서버에서 찾은 경우:
                        // let serverSchedule = ScheduleModel(id: scheduleModelUID, title: "서버", visitPlaces: [])
                        // self.localSchedules.append(serverSchedule)
                        // self.cache.setObject(serverSchedule as AnyObject, forKey: cacheKey)
                        // promise(.success(serverSchedule))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func readScheduleList(page: Int, itemsPerPage: Int) -> AnyPublisher<[ScheduleModel], Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(ScheduleError.unknown))
                return
            }
            
            let cacheKey = "list_page_\(page)_\(itemsPerPage)" as NSString

            // 1. 캐시에서 먼저 확인
            self.cacheQueue.async {
                if let cachedList = self.cache.object(forKey: cacheKey) as? [ScheduleModel] {
                    DispatchQueue.main.async {
                        promise(.success(cachedList))
                    }
                    return
                }
                
                // 2. 로컬에서 페이징 처리
                let startIndex = page * itemsPerPage
                let endIndex = min(startIndex + itemsPerPage, self.localSchedules.count)
                
                // 서버에서 가져오기
                DispatchQueue.global(qos: .background).async {
                
                                
                    guard startIndex < self.localSchedules.count else {
                        DispatchQueue.main.async {
                            promise(.success([]))
                        }
                        return
                    }
                    
                    let pageData = Array(self.localSchedules[startIndex..<endIndex])

                    // 캐시에 저장
                    self.cacheQueue.async {
                        self.cache.setObject(pageData as AnyObject, forKey: cacheKey, cost: pageData.count)
                    }
                    
                    DispatchQueue.main.async {
                        promise(.success(pageData))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateSchedule(_ scheduleModel: ScheduleModel) -> AnyPublisher<ScheduleModel, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(ScheduleError.unknown))
                return
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                // 로컬에서 업데이트
                if let index = self.localSchedules.firstIndex(where: { $0.uid == scheduleModel.uid }) {
                    self.localSchedules[index] = scheduleModel
                    
                    // 관련 캐시 무효화
                    self.invalidateScheduleCache(uid: scheduleModel.id)
                    
                    DispatchQueue.main.async {
                        promise(.success(scheduleModel))
                    }
                } else {
                    DispatchQueue.main.async {
                        promise(.failure(ScheduleError.notFound))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteSchedule(scheduleModelUID: String) -> AnyPublisher<Void, Error> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.failure(ScheduleError.unknown))
                return
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.localSchedules.removeAll { $0.uid == scheduleModelUID }
                
                // 관련 캐시 무효화
                self.invalidateScheduleCache(uid: scheduleModelUID)
                self.invalidateCache()
                
                DispatchQueue.main.async {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Private Methods
    
    private func invalidateScheduleCache(uid: String) {
        cacheQueue.async {
            let key = "schedule_\(uid)" as NSString
            self.cache.removeObject(forKey: key)
        }
    }
    
    
    private func invalidateCache() {
        cacheQueue.async {
            self.cache.removeAllObjects()
        }
    }
}

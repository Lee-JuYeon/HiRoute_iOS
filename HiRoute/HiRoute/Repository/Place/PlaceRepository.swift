//
//  PlanrepositoryProtocol.swift
//  HiRoute
//
//  Created by Jupond on 7/26/25.
//
// MARK: - Repository Implementations
import Foundation
import Combine

class PlaceRepository: PlaceProtocol {
    
    // 메모리 캐시 - 최대 100개 항목만 유지
    private var cache = NSCache<NSString, AnyObject>()
    private let cacheQueue = DispatchQueue(label: "com.place.cache", qos: .utility)
    
    init() {
        setupCache()
//        loadInitialData()
    }
    
    // ✅ 캐시 설정 추가
    private func setupCache() {
        cache.countLimit = 100
        cache.totalCostLimit = 10 * 1024 * 1024 // 10MB
    }
    
    // ✅ 캐시 정리 메소드 추가
    func clearCache() {
        cacheQueue.async { [weak self] in
            self?.cache.removeAllObjects()
        }
    }
    
    func optimizeCache() {
        cacheQueue.async { [weak self] in
            guard let self = self else { return }
            let oldLimit = self.cache.totalCostLimit
            self.cache.totalCostLimit = oldLimit / 2
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.cache.totalCostLimit = oldLimit
            }
        }
    }
    
    func createPlace(_ place: PlaceModel) -> AnyPublisher<PlaceModel, Error> {
        Future { promise in
            DispatchQueue.global(qos: .userInitiated).async {
                // API 호출 시뮬레이션
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    promise(.success(place))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func readPlace(placeUID: String) -> AnyPublisher<PlaceModel, Error> {
        Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
                if let place = DummyPack.samplePlaces.first(where: { $0.uid == placeUID }) {
                    promise(.success(place))
                } else {
                    promise(.failure(ServiceError.dataNotFound))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func readPlaceList(page: Int, itemsPerPage: Int) -> AnyPublisher<[PlaceModel], Error> {
        Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.4) {
                
                // ✅ 페이지 값 검증
                guard page >= 0, itemsPerPage > 0 else {
                    print("PlaceRepository, readPlaceList // Warning : 잘못된 페이지 파라미터 - page:\(page), itemsPerPage:\(itemsPerPage)")
                    promise(.success([]))
                    return
                }
                
                // ✅ 수정: 0부터 시작하는 페이지 계산
                let startIndex = page * itemsPerPage
                let endIndex = min(startIndex + itemsPerPage, DummyPack.samplePlaces.count)
                
                // ✅ 범위 검증 강화
                guard startIndex >= 0 && startIndex < DummyPack.samplePlaces.count else {
                    print("PlaceRepository, readPlaceList // Info : 요청된 페이지 범위 초과 - page:\(page)")
                    promise(.success([]))
                    return
                }
                
                let pageData = Array(DummyPack.samplePlaces[startIndex..<endIndex])
                print("PlaceRepository, readPlaceList // Success : 페이지 데이터 조회 완료 - page:\(page), count:\(pageData.count)")
                promise(.success(pageData))
            }
        }.eraseToAnyPublisher()
    }
    
    func updatePlace(_ place: PlaceModel) -> AnyPublisher<PlaceModel, Error> {
        Future { promise in
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    promise(.success(place))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func deletePlace(placeUID: String) -> AnyPublisher<PlaceModel, Error> {
        Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                // 삭제하려는 Place 찾기
                if let deletedPlace = DummyPack.samplePlaces.first(where: { $0.uid == placeUID }) {
                    // 실제 구현에서는 여기서 서버에서 삭제하고, 삭제된 모델을 반환
                    promise(.success(deletedPlace))
                } else {
                    promise(.failure(ServiceError.dataNotFound))
                }
            }
        }.eraseToAnyPublisher()
    }
        
    
    func requestPlaceInfoEdit(placeUID: String, userUID: String, reportType: ReportType.RawValue, reason: String) -> AnyPublisher<Void, Error> {
        Future { promise in
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                print("📝 Place info edit requested: \(placeUID) - \(reportType)")
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }
}




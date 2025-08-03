//
//  StoreAPI.swift
//  HiRoute
//
//  Created by Jupond on 8/2/25.
//


import Foundation
import CoreLocation
import SwiftUI

// MARK: - 데이터 모델
struct StoreResponse: Codable {
    let header: ResponseHeader
    let body: ResponseBody
}

struct ResponseHeader: Codable {
    let resultCode: String
    let resultMsg: String
}

struct ResponseBody: Codable {
    let items: [Store]
    let numOfRows: Int
    let pageNo: Int
    let totalCount: Int
}

struct Store: Codable, Identifiable {
    let id = UUID()
    let bizesId: String        // 업소 고유 ID (비즈니스 식별자, 고유키)
    let bizesNm: String        // 상호명 (예: 스타벅스 홍대점)
    let brchNm: String?        // 지점명 또는 분점명 (예: 홍대점), 없을 수도 있음

    let indsLclsCd: String     // 업종 대분류 코드 (예: "Q01")
    let indsLclsNm: String     // 업종 대분류명 (예: 음식점업)
    let indsMclsCd: String     // 업종 중분류 코드 (예: "Q12")
    let indsMclsNm: String     // 업종 중분류명 (예: 커피전문점)
    let indsSclsCd: String     // 업종 소분류 코드 (예: "Q12A01")
    let indsSclsNm: String     // 업종 소분류명 (예: 카페)

    let ctprvnNm: String?      // 시/도명 (예: 서울특별시)
    let signguNm: String?      // 시/군/구명 (예: 마포구)
    let adongNm: String?       // 읍/면/동명 (예: 서교동)

    let lnoAdr: String?        // 지번 주소 (예: 서울 마포구 서교동 123-4)
    let rdnmAdr: String?       // 도로명 주소 (예: 서울 마포구 홍익로5길 30)

    
    // 이 부분을 수정: String? -> Double?
    let lon: Double?
    let lat: Double?
    
    // 카드매출 데이터 (실제로는 별도 API에서 가져와야 함)
    var cardSales: Int {
        // 임시로 랜덤 값 사용 (실제로는 카드매출 API 연동 필요)
        return Int.random(in: 10000...500000)
    }
    
    // 좌표 변환 로직도 수정
    var coordinate: CLLocationCoordinate2D? {
        guard let longitude = lon, let latitude = lat else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // 거리 계산
    func distance(from location: CLLocationCoordinate2D) -> Double {
        guard let storeCoordinate = coordinate else { return Double.infinity }
        
        let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let storeLocation = CLLocation(latitude: storeCoordinate.latitude, longitude: storeCoordinate.longitude)
        
        return userLocation.distance(from: storeLocation)
    }
    // CodingKeys 추가 (필드명이 다를 경우)
      private enum CodingKeys: String, CodingKey {
          case bizesId, bizesNm, brchNm
          case indsLclsCd, indsLclsNm, indsMclsCd, indsMclsNm, indsSclsCd, indsSclsNm
          case ctprvnNm, signguNm, adongNm, lnoAdr, rdnmAdr
          case lon, lat
      }
  }


// 현재 위치 마커 데이터 구조체
struct CurrentLocationMarker: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct StoreMarker: Identifiable {
    let id = UUID()
    let store: Store
    let coordinate: CLLocationCoordinate2D
    
    init(store: Store) {
        self.store = store
        self.coordinate = store.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
}


// MARK: - 위치 매니저
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestLocationPermission() {
        guard CLLocationManager.locationServicesEnabled() else { return }
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 업데이트 실패: \(error.localizedDescription)")
    }
}

// MARK: - API 서비스
class StoreAPIService {
    private let baseURL = "https://apis.data.go.kr/B553077/api/open/sdsc2"
   
    
    func fetchStoresInRadius(
        latitude: Double,
        longitude: Double,
        radius: Int = 100,
        completion: @escaping (Result<[Store], Error>) -> Void
    ) {
        // 인코딩된 키 사용 (첫 번째 시도에서 성공했던 키)
        let encodedServiceKey = "Vspb8R%2Bu%2BPLvGZ%2FLKjWADh3oM5uIZ2B5FEeJyo1eCoY%2BNjWrb1bay54C%2BZVx%2F%2BV0HeQlWGWwJFlSViuAB7ZjgQ%3D%3D"
        
        let urlString = "https://apis.data.go.kr/B553077/api/open/sdsc2/storeListInRadius?serviceKey=\(encodedServiceKey)&pageNo=1&numOfRows=10&radius=\(radius)&cx=\(longitude)&cy=\(latitude)&type=json"
        
        guard let url = URL(string: urlString) else {
            print("❌ URL 생성 실패")
            return
        }
        
        print("🔗 요청 URL: \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ 네트워크 에러: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📊 HTTP 상태 코드: \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: 0, userInfo: [NSLocalizedDescriptionKey: "데이터를 받을 수 없습니다."])))
                return
            }
            
            // 응답 데이터 확인
            if let responseString = String(data: data, encoding: .utf8) {
                print("📝 응답 데이터: \(responseString.prefix(500))...")
            }
            
            do {
                let storeResponse = try JSONDecoder().decode(StoreResponse.self, from: data)
                
                if storeResponse.header.resultCode == "00" {
                    let userLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    let sortedStores = storeResponse.body.items.sorted {
                        $0.distance(from: userLocation) < $1.distance(from: userLocation)
                    }
                    completion(.success(sortedStores))
                } else {
                    let error = NSError(domain: "APIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "API 오류: \(storeResponse.header.resultMsg)"])
                    completion(.failure(error))
                }
            } catch {
                print("❌ JSON 파싱 에러: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
}

// MARK: - ViewModel
class OpenAPIVM: ObservableObject {
    @Published var stores: [Store] = []
    @Published var storeMarkers: [StoreMarker] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = StoreAPIService()
    private let locationManager = LocationManager()
    
    func requestLocationPermission() {
        locationManager.requestLocationPermission()
    }
    
    func fetchNearbyStores(center: CLLocationCoordinate2D) {
        isLoading = true
        errorMessage = nil
        
        apiService.fetchStoresInRadius(
            latitude: center.latitude,
            longitude: center.longitude
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let stores):
                    self?.stores = stores
                    
                    // 디버깅: 각 업소의 좌표 정보 확인
                    print("📍 업소별 좌표 정보:")
                    for (index, store) in stores.enumerated() {
                        print("[\(index)] \(store.bizesNm)")
                        print("   - lon: \(store.lon ?? 0.0)")
                        print("   - lat: \(store.lat ?? 0.0)")
                        print("   ---")
                    }
                    
                    self?.storeMarkers = stores.compactMap { store in
                        guard store.coordinate != nil else {
                            print("⚠️ 좌표 없는 업소: \(store.bizesNm)")
                            return nil
                        }
                        return StoreMarker(store: store)
                    }
                    print("✅ \(stores.count)개의 업소를 찾았습니다.")
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("❌ API 호출 실패: \(error.localizedDescription)")
                }
            }
        }
    }
}


// MARK: - 통합된 ViewModel
class SearchViewModel: ObservableObject {
    // 위치 관련
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    // 지도 관련
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @Published var centerPinCoordinate = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
    
    // 검색 관련
    @Published var searchText: String = ""
    @Published var stores: [Store] = []
    @Published var storeMarkers: [StoreMarker] = []
    @Published var selectedStore: Store?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // UI 상태
    @Published var hasInitializedLocation = false
    @Published var showStoreList = false
    
    private let locationManager = CLLocationManager()
    private let apiService = StoreAPIService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupLocationManager()
        setupRegionObserver()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
    
    private func setupRegionObserver() {
        // region 변경 시 centerPinCoordinate 업데이트
        $region
            .map { $0.center }
            .assign(to: \.centerPinCoordinate, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Location Methods
    func requestLocationPermission() {
        guard CLLocationManager.locationServicesEnabled() else { return }
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
    
    func updateLocationIfNeeded(_ newLocation: CLLocationCoordinate2D) {
        if !hasInitializedLocation {
            withAnimation(.easeInOut(duration: 1.0)) {
                region = MKCoordinateRegion(
                    center: newLocation,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            }
            hasInitializedLocation = true
        }
    }
    
    // MARK: - Search Methods
    func searchNearbyStores() {
        isLoading = true
        errorMessage = nil
        
        apiService.fetchStoresInRadius(
            latitude: centerPinCoordinate.latitude,
            longitude: centerPinCoordinate.longitude
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let stores):
                    self?.stores = stores
                    self?.storeMarkers = stores.compactMap { store in
                        guard store.coordinate != nil else { return nil }
                        return StoreMarker(store: store)
                    }
                    self?.showStoreList = !stores.isEmpty
                    print("✅ \(stores.count)개의 업소를 찾았습니다.")
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("❌ API 호출 실패: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func selectStore(_ store: Store) {
        selectedStore = store
        // 선택한 업소로 지도 중심 이동
        if let coordinate = store.coordinate {
            withAnimation(.easeInOut(duration: 0.5)) {
                region = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                )
            }
        }
    }
    
    func hideStoreList() {
        showStoreList = false
    }
}

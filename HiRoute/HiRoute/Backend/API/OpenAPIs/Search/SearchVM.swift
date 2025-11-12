//
//  SearchVM.swift
//  HiRoute
//
//  Created by Jupond on 8/3/25.
//
import Foundation
import CoreLocation
import SwiftUI
import MapKit
import Combine

// MARK: - 통합된 ViewModel
class SearchVM:  NSObject, ObservableObject {
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
    
    override init() {
        super.init() 
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

// MARK: - CLLocationManagerDelegate
extension SearchVM: CLLocationManagerDelegate {
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
        updateLocationIfNeeded(location.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 업데이트 실패: \(error.localizedDescription)")
    }
}

//
//  MapCoordinator.swift
//  HiRoute
//
//  Created by Jupond on 11/12/25.
//

import SwiftUI
import MapKit
import Combine

// MARK: - Zoom Tier (줌 레벨별 표시 타입 결정)

enum ZoomTier {
    case far      // latitudeDelta > 0.05 (~5km+)
    case medium   // 0.01 ~ 0.05 (~1~5km)
    case close    // < 0.01 (~1km 이내)

    static func from(latitudeDelta: Double) -> ZoomTier {
        if latitudeDelta > 0.05 { return .far }
        if latitudeDelta >= 0.01 { return .medium }
        return .close
    }

    /// 줌 티어별 API limit (인기순 정렬과 조합 — 줌 아웃 시 인기 장소만 노출)
    var limit: Int {
        switch self {
        case .far: return 50
        case .medium: return 100
        case .close: return 200
        }
    }
}

class MapCoordinator: ObservableObject {

    /// 화면 전환 시 region 보존 (HomeView 파괴되어도 유지)
    private static var savedRegion: MKCoordinateRegion?

    /// 추천 장소 캐시 — 앱 라이프사이클 동안 1회만 API 호출
    private static var cachedRecommendPlaces: [PlaceModel]?

    /// 뷰포트 캐시 — 줌 티어별 최근 결과 1개 보관
    private static var viewportCache: [ZoomTier: (center: CLLocationCoordinate2D, radius: Int, places: [PlaceModel])] = [:]

    @Published var mapRegion = MapCoordinator.savedRegion ?? MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @Published var searchResults: [MKMapItem] = []
    @Published var selectedHotPlaceIds: Set<String> = ["yeonmujang_gil", "garosu_gil", "hongdae"]
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let useCase: MapUseCase
    private var cancellables = Set<AnyCancellable>()

    /// 마지막으로 API 호출한 뷰포트 파라미터 (중복 호출 방지)
    private var lastFetchedTier: ZoomTier?
    private var lastFetchedCenter: CLLocationCoordinate2D?
    private var lastFetchedRadius: Int?

    init(useCase: MapUseCase) {
        self.useCase = useCase

        $mapRegion
            .sink { MapCoordinator.savedRegion = $0 }
            .store(in: &cancellables)

        loadInitialData()
        setupViewportDebounce()
    }

    @Published var annotations: [PlaceModel] = []
    @Published var hotPlaces: [HotPlaceModel] = []
    @Published var recommendPlaces: [PlaceModel] = []
    @Published var geoObjects: [GeoObjectModel] = []

    private func loadInitialData() {
        // HotPlaces are still local data
        hotPlaces = useCase.getHotPlaces()
        geoObjects = useCase.getGeoObjects()

        // 캐시된 추천 장소가 있으면 API 호출 스킵
        if let cached = MapCoordinator.cachedRecommendPlaces {
            recommendPlaces = cached
            fetchForCurrentViewport()
            return
        }

        // Fetch recommendations from API (zoom-independent)
        guard let apiUseCase = useCase as? MapUseCaseImpl else {
            annotations = useCase.getAnnotations()
            recommendPlaces = useCase.getRecommendPlaces()
            return
        }

        apiUseCase.fetchRecommendPlacesFromAPI()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("MapCoordinator, loadRecommendPlaces // Error : \(error.localizedDescription)")
                    }
                },
                receiveValue: { [weak self] places in
                    self?.recommendPlaces = places
                    MapCoordinator.cachedRecommendPlaces = places
                }
            )
            .store(in: &cancellables)

        // 초기 뷰포트에 대해 어노테이션 로드 (디바운스 대기 없이)
        fetchForCurrentViewport()
    }

    // MARK: - Viewport-based Annotation Loading

    /// 300ms 디바운스: region 변경 후 안정되면 뷰포트 기반 API 호출
    private func setupViewportDebounce() {
        $mapRegion
            .dropFirst() // 초기값 스킵 (loadInitialData에서 처리)
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.fetchForCurrentViewport()
            }
            .store(in: &cancellables)
    }

    /// 현재 뷰포트 기반으로 API 호출 (중복 호출 방지 + 캐싱 포함)
    private func fetchForCurrentViewport() {
        guard let apiUseCase = useCase as? MapUseCaseImpl else { return }

        let region = mapRegion
        let tier = ZoomTier.from(latitudeDelta: region.span.latitudeDelta)
        let lat = region.center.latitude
        let lon = region.center.longitude
        // span → radius (미터): 시각 원 크기에 맞춤 (뷰포트의 약 50%)
        let radius = Int(region.span.latitudeDelta * 111000.0 / 4.0)

        // 중복 호출 방지: 동일 티어 + 유사 좌표(epsilon 이내) + 동일 반경
        if let lastTier = lastFetchedTier,
           let lastCenter = lastFetchedCenter,
           let lastRadius = lastFetchedRadius,
           lastTier == tier,
           lastRadius == radius,
           abs(lat - lastCenter.latitude) < 0.002,
           abs(lon - lastCenter.longitude) < 0.002 {
            return
        }

        // 뷰포트 캐시 확인: 같은 티어 + 유사 영역이면 캐시 반환
        if let cached = MapCoordinator.viewportCache[tier],
           cached.radius == radius,
           abs(lat - cached.center.latitude) < 0.002,
           abs(lon - cached.center.longitude) < 0.002 {
            annotations = cached.places
            lastFetchedTier = tier
            lastFetchedCenter = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            lastFetchedRadius = radius
            return
        }

        lastFetchedTier = tier
        lastFetchedCenter = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        lastFetchedRadius = radius

        apiUseCase.fetchAnnotationsForViewport(
            lat: lat,
            lon: lon,
            radius: radius,
            limit: tier.limit
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("MapCoordinator, fetchViewport // Error : \(error.localizedDescription)")
                }
            },
            receiveValue: { [weak self] places in
                self?.annotations = places
                MapCoordinator.viewportCache[tier] = (
                    center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                    radius: radius,
                    places: places
                )
            }
        )
        .store(in: &cancellables)
    }

    // 검색 기능
    @Published var searchText: String = ""
    func searchLocation(_ query: String) {
        guard !query.isEmpty else { return }

        searchText = query
        isLoading = true
        errorMessage = nil

        Task { @MainActor in
            do {
                let result = try await useCase.searchLocation(query, currentRegion: mapRegion)

                searchResults = result.mapItems

                if let newRegion = result.newRegion {
                    withAnimation(.easeInOut(duration: 1.0)) {
                        mapRegion = newRegion
                    }
                }

                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }




    // HotPlace 관리 기능들
    func toggleHotPlace(_ id: String) {
        if selectedHotPlaceIds.contains(id) {
            selectedHotPlaceIds.remove(id)
        } else {
            selectedHotPlaceIds.insert(id)
        }
    }

    func showAllHotPlaces() {
        selectedHotPlaceIds = Set(hotPlaces.map { $0.id })
        moveToShowAllHotPlaces()
    }

    func hideAllHotPlaces() {
        selectedHotPlaceIds.removeAll()
    }

    private func moveToShowAllHotPlaces() {
        let allCoordinates = hotPlaces.flatMap { $0.coordinates }
        guard !allCoordinates.isEmpty else { return }

        let minLat = allCoordinates.map { $0.latitude }.min() ?? 0
        let maxLat = allCoordinates.map { $0.latitude }.max() ?? 0
        let minLon = allCoordinates.map { $0.longitude }.min() ?? 0
        let maxLon = allCoordinates.map { $0.longitude }.max() ?? 0

        withAnimation(.easeInOut(duration: 1.0)) {
            mapRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: (minLat + maxLat) / 2,
                    longitude: (minLon + maxLon) / 2
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: (maxLat - minLat) * 1.5,
                    longitudeDelta: (maxLon - minLon) * 1.5
                )
            )
        }
    }

    deinit {
        cancellables.removeAll()
    }
}

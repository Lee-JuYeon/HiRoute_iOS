//
//  HomeMapContent.swift
//  HiRoute
//
//  Created by Jupond on 5/25/26.
//

import SwiftUI
import MapKit

/// HomeView(지도 탭)의 맵 컨텐츠 본체 — 추출하여 fullScreenCover에서도 재사용.
/// 호출부:
/// - `HomeView` : `HomeMapContent()` 기본 사용 (추천만)
/// - `ScheduleFullscreenMapView` : `HomeMapContent(additionalPlans: schedule.planList)`
///   → 추천 마커는 그대로 + 그 위에 plans를 번호 마커 + 점선으로 오버레이 (PlanMapView 외관)
struct HomeMapContent: View {

    /// 일정 plans — 비어있지 않으면 PlanMapOverlayView로 번호 마커 + 점선 오버레이.
    let additionalPlans: [PlanModel]

    @EnvironmentObject private var naviVM: NavigationVM
    @EnvironmentObject private var scheduleVM: ScheduleVM
    @EnvironmentObject private var placeVM: PlaceVM
    @StateObject private var coordinator = MapCoordinator(
        useCase: MapUseCaseImpl(
            repository: MapRepositoryImpl()
        )
    )

    @State private var chipSelections: [String: Set<String>] = [:]

    init(additionalPlans: [PlanModel] = []) {
        self.additionalPlans = additionalPlans
    }

    // MARK: - Filtering

    private func matchesFilter(_ place: PlaceModel) -> Bool {
        if chipSelections.isEmpty { return true }
        let typeKey = place.type.rawValue
        guard let selectedSubs = chipSelections[typeKey] else { return false }
        if selectedSubs.isEmpty { return true }
        guard let subtype = place.subtype else { return true }
        return selectedSubs.contains(subtype)
    }

    private var filteredAnnotations: [PlaceModel] {
        coordinator.annotations.filter { matchesFilter($0) }
    }

    private var filteredRecommendPlaces: [PlaceModel] {
        coordinator.recommendPlaces.filter { matchesFilter($0) }
    }

    private var bookmarkedPlaceIds: Set<String> {
        Set(placeVM.myBookmarkedPlaces.map { $0.uid })
    }

    // MARK: - Actions

    private func onClickSearchButton(_ text: String) {
        coordinator.searchLocation(text)
    }

    private func onClickAnnotation(_ model: PlaceModel) {
        placeVM.selectPlace(model)
        scheduleVM.currentPlanModel = PlanModel(
            uid: UUID().uuidString,
            index: 0,
            memo: "",
            placeModel: model,
            files: []
        )
        naviVM.currentPlaceModeType = .OTHER
        naviVM.navigateTo(setDestination: .place)
    }

    private func onClickBookMark(_ uid: String) {
        if let place = coordinator.recommendPlaces.first(where: { $0.uid == uid }) {
            placeVM.toggleBookmark(for: place)
        }
    }

    private func onCLickRecommendPlace(_ model: PlaceModel) {
        placeVM.selectPlace(model)
        scheduleVM.currentPlanModel = PlanModel(
            uid: UUID().uuidString,
            index: 0,
            memo: "",
            placeModel: model,
            files: []
        )
        naviVM.currentPlaceModeType = .OTHER
        naviVM.navigateTo(setDestination: .place)
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .top) {
            CustomMapView(
                region: $coordinator.mapRegion,
                searchResults: coordinator.searchResults,
                selectedHotPlaceIds: coordinator.selectedHotPlaceIds,
                listHotPlaces: coordinator.hotPlaces,
                geoObjects: coordinator.geoObjects,
                listAnnotations: filteredAnnotations,
                onClickAnnotation: { annotationModel in
                    onClickAnnotation(annotationModel)
                }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // 일정 plans 오버레이 — 번호 마커 + 점선 (PlanMapView와 동일 외관)
            if !additionalPlans.isEmpty {
                PlanMapOverlayView(
                    plans: additionalPlans,
                    region: coordinator.mapRegion
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(true)
            }

            VStack(spacing: 0) {
                SearchView(
                    onClickSearchButton: onClickSearchButton,
                    hint: "검색해봐요",
                    searchText: $coordinator.searchText
                )

                HorizontalChipView(
                    setList: placeVM.chipData,
                    setOnSelectionChanged: { selections in
                        chipSelections = selections
                    }
                )

                Spacer()
                    .allowsHitTesting(false)

                RecommendPlaceList(
                    setList: filteredRecommendPlaces,
                    setBookmarkedIds: bookmarkedPlaceIds,
                    setOnClickCell: { model in
                        onCLickRecommendPlace(model)
                    },
                    setOnClickBookMark: { uid in
                        onClickBookMark(uid)
                    }
                )
            }
        }
    }
}

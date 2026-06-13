//
//  SimpleUserModel.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI
import MapKit

struct PlaceSearchView : View {
    
    init() {
    }
    
    @State private var searchMode : SEARCH_MODE = .LIST_MODE
    enum SEARCH_MODE {
        case LIST_MODE
        case MAP_MODE
    }

    @EnvironmentObject private var navigationVM : NavigationVM
    @EnvironmentObject private var placeVM : PlaceVM
    @EnvironmentObject private var scheduleVM : ScheduleVM
    @State private var searchState: PlaceSearchState = .initial
    @State private var showDuplicateConfirm: Bool = false
    @State private var pendingPlace: PlaceModel? = nil
    @StateObject private var coordinator = MapCoordinator(
        useCase: MapUseCaseImpl(
            repository: MapRepositoryImpl()
        )
    )

  
    private func handleSearchEvent(text : String){
        searchState = .searching
        
        if placeVM.searchPlaces(text: text).isEmpty {
            searchState = .empty
        }else{
            searchState = .completed
        }
    }
    
    
    private func handleClickPlace(selectedPlaceModel : PlaceModel){
        placeVM.selectedPlace = selectedPlaceModel
        scheduleVM.currentPlanModel = PlanModel(
            uid: UUID().uuidString,
            index: scheduleVM.selectedSchedule?.planList.count ?? 0,
            memo: "",
            placeModel: selectedPlaceModel,
            files: []
        )
        navigationVM.currentPlaceModeType = .OTHER
        navigationVM.navigateTo(setDestination: .place)
    }
    
    private func handleAddPlace(selectedPlaceModel : PlaceModel){
        guard let schedule = scheduleVM.selectedSchedule else { return }

        // 이미 추가된 장소인 경우 확인 바텀시트 표시
        if isAlreadyAdded(selectedPlaceModel) {
            pendingPlace = selectedPlaceModel
            showDuplicateConfirm = true
            return
        }

        addPlaceToCurrentSchedule(selectedPlaceModel)
    }

    private func addPlaceToCurrentSchedule(_ selectedPlaceModel: PlaceModel) {
        guard let schedule = scheduleVM.selectedSchedule else { return }

        let newPlan = PlanModel(
            uid: UUID().uuidString,
            index: schedule.planList.count,
            memo: "",
            placeModel: selectedPlaceModel,
            files: []
        )

        var updatedPlanList = schedule.planList
        updatedPlanList.append(newPlan)

        let updatedSchedule = ScheduleModel(
            uid: schedule.uid,
            index: schedule.index,
            title: schedule.title,
            memo: schedule.memo,
            editDate: schedule.editDate,
            d_day: schedule.d_day,
            planList: updatedPlanList
        )

        scheduleVM.selectedSchedule = updatedSchedule

        navigationVM.navigateTo(setDestination: .plan)
        print("PlaceSearchView, handleAddPlace(Place추가) : \(selectedPlaceModel)")
    }
    
    // 검색 초기화 기능
    private func resetSearch() {
        searchState = .initial
        placeVM.searchText = ""
        placeVM.filteredPlaces = placeVM.recommendPlaces()
    }
    
    // ✅ 어노테이션 생성 함수 추가
    private func createAnnotations() -> [PlaceModel] {
        return searchState == .completed ? placeVM.filteredPlaces : placeVM.recommendPlaces()
    }
    
    @ViewBuilder
    private func noResultView() -> some View {
        VStack(alignment: HorizontalAlignment.center) {
            Spacer()
            
            Image("image_no_result")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
            
            Text("검색 결과가 없습니다.\n추천 장소를 보고싶다면 클릭해주세요 :)")
                .foregroundColor(Color.getColour(.label_alternative))
                .font(.system(size: 22))
                .onTapGesture {
                    resetSearch()
                }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
        
    @ViewBuilder
    private func customToolBar() -> some View {
        VStack(alignment: HorizontalAlignment.leading){
            HStack(alignment: VerticalAlignment.center){
                ImageButton(
                    imageUrl : "icon_back",
                    imageSize: 30
                ) {
                    navigationVM.navigateTo(setDestination: .plan)
                }
                 
                DoneTextField(
                    text: $placeVM.searchText,
                    placeholder: "추가하고 싶은 장소 검색",
                    onCommit: {
                        if placeVM.searchText.isEmpty {
                            searchState = .initial
                        } else {
                            handleSearchEvent(text: placeVM.searchText)
                        }
                    }
                )
                .frame(
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: 30
                )
                .disableAutocorrection(true)

                StateButton(
                    iconName: "icon_search",
                    isEnabled: !placeVM.searchText.isEmpty
                ) {
                    handleSearchEvent(text: placeVM.searchText)
                }
                .padding(10)
                .frame(
                    width: 40,
                    height: 40
                )
            }
            .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
            
            Rectangle()
                .fill(Color.getColour(.label_disable))
                .frame(
                    maxWidth: .infinity,
                    minHeight:1,
                    idealHeight: 1,
                    maxHeight: 1
                )
        }
    }
    
    private func isAlreadyAdded(_ placeModel: PlaceModel) -> Bool {
        guard let schedule = scheduleVM.selectedSchedule else { return false }
        return schedule.planList.contains { $0.placeModel.uid == placeModel.uid }
    }

    @ViewBuilder
    private func recommendList() -> some View {
        LazyVStack(alignment: HorizontalAlignment.leading, spacing: 0){
            ForEach(placeVM.recommendPlaces(), id: \.uid) { placeModel in
                PlaceCell(
                    setPlaceModel: placeModel,
                    setPlaceCellType: .HOT,
                    setIsAlreadyAdded: isAlreadyAdded(placeModel),
                    onClickAdd: {
                        handleAddPlace(selectedPlaceModel: placeModel)
                    },
                    onClickCell: { clickedPlaceModel in
                        handleClickPlace(selectedPlaceModel: clickedPlaceModel)
                    }
                )
                .onAppear {
                    if placeModel.uid == placeVM.places.last?.uid {
                        placeVM.loadMorePlaces()
                    }
                }
            }

            if placeVM.isLoadingMorePlaces {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding(.vertical, 16)
            }
        }
        .background(Color.clear)
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 8))
    }

    @ViewBuilder
    private func basicList() -> some View {
        LazyVStack(alignment: HorizontalAlignment.leading, spacing: 0){
            ForEach(placeVM.filteredPlaces, id: \.uid) { placeModel in
                PlaceCell(
                    setPlaceModel: placeModel,
                    setPlaceCellType: .NOMAL,
                    setIsAlreadyAdded: isAlreadyAdded(placeModel),
                    onClickAdd: {
                        handleAddPlace(selectedPlaceModel: placeModel)
                    },
                    onClickCell: { clickedPlaceModel in
                        handleClickPlace(selectedPlaceModel: clickedPlaceModel)
                    }
                )
            }
        }
        .background(Color.clear)
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 8))
    }
    
    @ViewBuilder
    private func mapSearchView() -> some View {
        VStack {
            customToolBar()  // ✅ 상단 검색바 유지
            
            CustomMapView(
                region: $coordinator.mapRegion,
                searchResults: coordinator.searchResults,
                selectedHotPlaceIds: [],
                listHotPlaces: [],
                geoObjects: coordinator.geoObjects,
                listAnnotations: createAnnotations(),
                onClickAnnotation: { clickedPlaceModel in
                    handleClickPlace(selectedPlaceModel: clickedPlaceModel)
                }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            switch searchMode {
            case .LIST_MODE:
                VStack(alignment: .leading) {
                    customToolBar()
                    
                    if searchState == .empty {
                        noResultView()
                    } else {
                        ScrollView(.vertical) {
                            switch searchState {
                            case .initial:
                                recommendList()
                            case .searching, .completed:
                                basicList()
                            case .empty:
                                EmptyView()
                            }
                        }
                    }
                }
                
            case .MAP_MODE:
                mapSearchView()  // ✅ mapSearchView 함수 사용
            }
           
            // 플로팅 버튼
            Button(action: {
                searchMode = (searchMode == .LIST_MODE) ? .MAP_MODE : .LIST_MODE
            }) {
                Image(searchMode == .LIST_MODE ? "icon_map_search" : "icon_list_search")
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(Color.getColour(.background_white))
                    .aspectRatio(contentMode: ContentMode.fit)
                    .frame(width: 30, height: 30)
            }
            .padding(10)
            .background(
                Circle()
                    .fill(Color.getColour(.label_strong))
            )
            .padding(20)
        }
        .bottomSheet(isOpen: $showDuplicateConfirm) {
            VStack(alignment: .center, spacing: 16) {
                Text("이미 추가된 장소입니다.\n추가할까요?")
                    .font(.system(size: 16))
                    .foregroundColor(Color.getColour(.label_strong))
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)

                HStack(spacing: 12) {
                    FillTextButton(text: "취소") {
                        showDuplicateConfirm = false
                        pendingPlace = nil
                    }
                    .frame(maxWidth: .infinity)

                    StrokeTextButton(text: "추가") {
                        showDuplicateConfirm = false
                        if let place = pendingPlace {
                            addPlaceToCurrentSchedule(place)
                            pendingPlace = nil
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
        }
    }
}

//
//  SimpleUserModel.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

struct PlaceSearchView : View {
    
    init(
    ){
    }
    
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var placeVM : PlaceVM
    @EnvironmentObject private var scheduleVM : ScheduleVM
    @EnvironmentObject private var planVM : PlanVM
    @State private var searchState: PlaceSearchState = .initial

    private func handleSearchEvent(text : String){
        searchState = .searching
        
        if placeVM.searchPlaces(text: text).isEmpty {
            searchState = .empty
        }else{
            searchState = .completed
        }
    }
    
    private func handleAddPlace(selectedPlaceModel : PlaceModel){
        planVM.createPlan(placeModel: selectedPlaceModel, files: [])
        presentationMode.wrappedValue.dismiss()
        print("PlaceSearchView, handleAddPlace(Place추가) : \(planVM.errorMessage)")
    }
    
    // 검색 초기화 기능
    private func resetSearch() {
        searchState = .initial
        placeVM.searchText = ""
        placeVM.filteredPlaces = placeVM.recommendPlaces()
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
                    imageURL : "icon_back",
                    imageSize: 30
                ) {
                    presentationMode.wrappedValue.dismiss()
                }
                
                TextField(
                    "추가하고 싶은 장소 검색",
                    text: $placeVM.searchText,
                    onCommit: {
                        if placeVM.searchText.isEmpty {
                            searchState = .initial
                        }
                    }
                )
                .frame(
                    maxWidth: .infinity
                )
                
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
    
    @ViewBuilder
    private func recommendList() -> some View {
        VStack(alignment: HorizontalAlignment.leading, spacing: 0){
            ForEach(placeVM.recommendPlaces(), id: \.uid) { placeModel in
                PlaceCell(
                    setImageURL: placeModel.thumbanilImageURL ?? "",
                    setTheme: placeModel.type.displayText,
                    setTitle: placeModel.title,
                    setPlaceCellType: .HOT,
                    callBackClick: {
                        handleAddPlace(selectedPlaceModel: placeModel)
                    }
                )
            }
        }
        .background(Color.clear)
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 8))
    }
    
    @ViewBuilder
    private func basicList() -> some View {
        VStack(alignment: HorizontalAlignment.leading, spacing: 0){
            ForEach(placeVM.filteredPlaces, id: \.uid) { placeModel in
                PlaceCell(
                    setImageURL: placeModel.thumbanilImageURL ?? "",
                    setTheme: placeModel.type.displayText,
                    setTitle: placeModel.title,
                    setPlaceCellType: .NOMAL,
                    callBackClick: {
                        handleAddPlace(selectedPlaceModel: placeModel)
                    }
                )
            }
        }
        .background(Color.clear)
        .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 8))
    }
    
    
    var body: some View {
        VStack(alignment: .leading) {
            customToolBar()
            
            // empty 상태는 ScrollView 밖에서 처리
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
                        EmptyView()  // 이미 위에서 처리됨
                    }
                }
            }
        }
        .onAppear {
            print("PlaceSearchView, onAppear : \(scheduleVM.selectedSchedule?.title)")
            planVM.currentPlanList = scheduleVM.selectedSchedule?.planList ?? []
        }
    }
}

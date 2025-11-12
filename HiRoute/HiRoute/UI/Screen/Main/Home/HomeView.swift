//
//  HomeView.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI
import MapKit

struct HomeView: View {
   
    @EnvironmentObject private var planVM : PlanViewModel
    @EnvironmentObject private var naviVM : NavigationVM
    @EnvironmentObject private var searchvM : SearchViewModel
    @StateObject private var coordinator = MapCoordinator()

    @ViewBuilder
    private func routeButton() -> some View {
        Button(action: {
            naviVM.navigateTo(setDestination: AppDestination.planDetail)
        }) {
            Image("img_route_create")
                .resizable() // 이 부분이 핵심!
                .aspectRatio(contentMode: ContentMode.fit)
                .frame(
                    maxWidth: .infinity
                )
                .frame(height: 113)
                .clipped()
                .background(Color.white)
                .cornerRadius(12)

        }
        .padding(
            EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0)
        )
        .customElevation(.normal)
    }
   
    @State private var searchText: String = ""
    private func onClickSearchButton(_ text: String) {
        coordinator.searchLocation(text)
    }
    
    private func onClickHorizontalChipView(_ model: HorizontalChipModel) {
        coordinator.searchLocation(model.text)
    }
           
  
   
    var body: some View {
//        ScrollView {
//            VStack(spacing: 0) {
//                
//               
//                search()
//                
//                RouteButton {
//                    naviVM.navigateTo(setDestination: AppDestination.planDetail)
//                }
//                
//                TrendPlaceSection(
//                    setTitle: hotPlaceTitle,
//                    setList: planVM.trendRoutes,
//                    setOnClickCell: { routeModel in
//                       
//                    },
//                    setOnClickBookMark: { routeUid in
//                        
//                    }
//                )
//               
//                // 인기 루트 섹션
//                LocalisedPlaceSection(
//                    getTitle: placetitle,
//                    getOnClickTotal: {
//                        
//                    },
//                    getList: planVM.localisedRoutes,
//                    getOnClickCell: { placeModel in
//                       
//                    },
//                    getOnClickBookMark: { isBookMarked in
//                        
//                    }
//                )
//              
//               
//            }
//
//        }
//        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
//        .background(Color.getColour(.background_yellow_white))
       

        ZStack(alignment: .top) {
            CustomMapView(
                region: $coordinator.mapRegion,
                searchResults: coordinator.searchResults,
                hotPlaces: coordinator.hotPlaces,
                selectedHotPlaceIds: coordinator.selectedHotPlaceIds
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity) // 화면 전체 크기로 확장
            
            
            // 상단 검색 UI (Z축 상위)
            VStack(spacing: 0) {
                SearchView(
                    onClickSearchButton: onClickSearchButton,
                    hint: "검색해봐요",
                    searchText: $searchText
                )
                
                HorizontalChipView(
                    setList: HorizontalChipView.sampleData,
                    setOnClick: onClickHorizontalChipView
                )
                
                Spacer()
            }
        }

    }
    
}


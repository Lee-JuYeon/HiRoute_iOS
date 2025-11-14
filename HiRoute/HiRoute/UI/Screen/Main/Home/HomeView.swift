//
//  HomeView.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI
import MapKit

struct HomeView: View {
   
    @EnvironmentObject private var naviVM : NavigationVM
    @StateObject private var coordinator = MapCoordinator(
        useCase: MapUseCaseImpl(
            repository: MapRepositoryImpl()
        )
    )

   
    private func onClickSearchButton(_ text: String) {
        coordinator.searchLocation(text)
    }
    
    private func onClickHorizontalChipView(_ model: HorizontalChipModel) {
        coordinator.searchLocation(model.text)
    }
           
    @State private var isShowAnnotationSheet = false
    @State private var selectedModel : PlaceModel? = nil
    private func onClickAnnotation(_ model: PlaceModel) {
        isShowAnnotationSheet = true
        selectedModel = model
    }
           
  
    private func onClickBookMark(_ uid : String){
        
    }
    
    private func onCLickRecommendPlace(_ model : PlaceModel){
        
    }
   
    var body: some View {
        ZStack(alignment: .top) {
            CustomMapView(
                region: $coordinator.mapRegion,
                searchResults: coordinator.searchResults,
                selectedHotPlaceIds: coordinator.selectedHotPlaceIds,
                listHotPlaces: coordinator.hotPlaces,
                listAnnotations: coordinator.annotations,
                onClickAnnotation: { annotationModel in
                    onClickAnnotation(annotationModel)
                }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity) // 화면 전체 크기로 확장
            
            
            // 상단 검색 UI (Z축 상위)
            VStack(spacing: 0) {
                SearchView(
                    onClickSearchButton: onClickSearchButton,
                    hint: "검색해봐요",
                    searchText: $coordinator.searchText
                )
                
                HorizontalChipView(
                    setList: HorizontalChipView.sampleData,
                    setOnClick: onClickHorizontalChipView
                )
                
                Spacer()
                
                RecommendPlaceList(
                    setList: coordinator.recommendPlaces,
                    setOnClickCell: { model in
                        onCLickRecommendPlace(model)
                    },
                    setOnClickBookMark: { uid in
                        onClickBookMark(uid)
                    }
                )
            }
        }
        .bottomSheet(isOpen: $isShowAnnotationSheet) {
            if let model = selectedModel {
                switch model.type {
                case .cafe :
                    SheetTravelSpotView(model: model, onClose: {
                        
                    })
                case .hospital:
                    SheetTravelSpotView(model: model, onClose: {
                        
                    })
                case .store:
                    SheetTravelSpotView(model: model, onClose: {
                        
                    })
                case .restaurant:
                    SheetTravelSpotView(model: model, onClose: {
                        
                    })
                }
            }else{
               Text("selectedModel = nil")
            }
        }
    }
}


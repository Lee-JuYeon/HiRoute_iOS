//
//  StoreListView.swift
//  HiRoute
//
//  Created by Jupond on 8/3/25.
//
import SwiftUI

struct PlanBottomSection: View {
    private var getVisitPlaceList : [VisitPlaceModel]
    private var getOnClickCell : (VisitPlaceModel) -> Void
    private var getOnClickAnnotation : (VisitPlaceModel) -> Void
    init(
        setVisitPlaceList : [VisitPlaceModel],
        onClickCell : @escaping (VisitPlaceModel) -> Void,
        onClickAnnotation : @escaping (VisitPlaceModel) -> Void
    ){
        self.getVisitPlaceList = setVisitPlaceList
        self.getOnClickCell = onClickCell
        self.getOnClickAnnotation = onClickAnnotation
    }
    
    @State private var selectedTabIndex = 0
    private let tabTitles = ["타임라인", "지도"]
    
    @ViewBuilder
    private func tabHeader() -> some View {
        HStack(spacing: 0) {
            ForEach(Array(tabTitles.enumerated()), id: \.offset) { index, title in
                VStack(spacing: 0) {
                    // 탭 텍스트
                    Text(title)
                        .font(.system(size: 14, weight: selectedTabIndex == index ? .bold : .regular))
                        .foregroundColor(selectedTabIndex == index ? Color.getColour(.label_strong) : Color.getColour(.label_alternative))
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            selectedTabIndex = index
                        }
                    
                    // 인디케이터 밑줄
                    Rectangle()
                        .fill(selectedTabIndex == index ? Color.getColour(.label_strong) : Color.getColour(.line_alternative))
                        .frame(height: 2)
                }
            }
        }
        .background(Color.clear)
    }
    
    @ViewBuilder
    private func tabContent() -> some View {
        TabView(selection: $selectedTabIndex) {
            TimeLineListView(
                setPlanModel: getVisitPlaceList,
                setOnClickCell: { clickedVisitPlaceModel in
                    getOnClickCell(clickedVisitPlaceModel)
                    
                }
            )
            .tag(0)
            
            PlanMapView(
                setVisitPlaceList: getVisitPlaceList,
                setOnClickAnnotation: { selectedVisitPlaceModel in
                    getOnClickAnnotation(selectedVisitPlaceModel)
                }
            )
            .tag(1)
          
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .animation(.easeInOut, value: selectedTabIndex)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 탭 헤더
            tabHeader()
            
            // 컨텐츠 영역
            tabContent()
        }
    }
}

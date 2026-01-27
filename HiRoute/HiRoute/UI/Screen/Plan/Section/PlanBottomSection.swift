//
//  StoreListView.swift
//  HiRoute
//
//  Created by Jupond on 8/3/25.
//
import SwiftUI


struct PlanBottomSection: View {
    private var getVisitPlaceList : [PlanModel]
    private var getOnClickCell : (PlanModel) -> Void
    private var getOnClickAnnotation : (PlanModel) -> Void
    private var getModeType : ModeType
    
    @Binding private var getFileList: [FileModel]
    private let onFilesChanged: (([FileModel]) -> Void)?
    init(
        setVisitPlaceList : [PlanModel],
        setModeType : ModeType,
        setFileList: Binding<[FileModel]>,
        onFilesChanged: (([FileModel]) -> Void)? = nil,
        onClickCell : @escaping (PlanModel) -> Void,
        onClickAnnotation : @escaping (PlanModel) -> Void
    ){
        self.getVisitPlaceList = setVisitPlaceList
        self.getModeType = setModeType
        self.getOnClickCell = onClickCell
        self.getOnClickAnnotation = onClickAnnotation
        self._getFileList = setFileList
        self.onFilesChanged = onFilesChanged
    }
    
    @State private var selectedTabIndex = 0
    private let tabTitles = ["타임라인", "지도", "문서"]
    
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
                    
                    // 인디케이터 밑줄
                    Rectangle()
                        .fill(selectedTabIndex == index ? Color.getColour(.label_strong) : Color.getColour(.line_alternative))
                        .frame(height: 2)
                }
                .onTapGesture {
                    selectedTabIndex = index
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
                setModeType: getModeType,
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
            
            FileView(
                visibleAddButton: .constant({
                    let shouldShow = getModeType == .CREATE || getModeType == .UPDATE 
                       print("🔍 FileView 버튼 가시성 - 모드: \(getModeType), 보이기: \(shouldShow)")
                       return shouldShow
                   }()),
                fileList: $getFileList,
                onFilesChanged: { updatedFileList in
                    onFilesChanged?(updatedFileList)
                }
            )
            .tag(2)
          
        }
//        .allowsHitTesting(false) // 터치 비활성화 (스크롤 막힘)
//        .disabled(true)
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

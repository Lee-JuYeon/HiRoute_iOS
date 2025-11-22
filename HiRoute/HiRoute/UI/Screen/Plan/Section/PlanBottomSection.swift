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
            
            FileView()
                .tag(2)
          
        }
        .allowsHitTesting(false) // 터치 비활성화 (스크롤 막힘)
        .disabled(true)
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

struct FileView : View {
    
    
    
    @State private var presentDocumentPicker : Bool = false
    @ViewBuilder
    private func addFileButton() -> some View {
        Button {
            presentDocumentPicker = true
        } label: {
            HStack(alignment: .center, spacing: 0){
                Text("여행에 관한 문서를 추가해볼까요?")
                    .font(.system(size: 20))
                    .foregroundColor(Color.getColour(.background_white))
                    .fontWeight(.light)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image("icon_arrow")
                    .renderingMode(.template)
                    .resizable()
                    .scaleEffect(x: -1, y: 1)
                    .foregroundColor(Color.getColour(.background_white))
                    .aspectRatio(contentMode: ContentMode.fit)
                    .frame(width: 16, height: 16)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
        .background(Color.getColour(.label_strong))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
    }
    
    var body: some View {
        VStack(alignment: HorizontalAlignment.leading, spacing: 10){
            addFileButton()
            
            FileListView(
                isPresentDocumentPicker: $presentDocumentPicker
            )
        }
    }
}

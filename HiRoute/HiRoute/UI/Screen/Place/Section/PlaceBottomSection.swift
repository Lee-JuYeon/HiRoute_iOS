//
//  UserModel.swift
//  HiRoute
//
//  Created by Jupond on 7/26/25.
//
import SwiftUI

struct PlaceBottomSection : View {
    
    private var getPlanModel : PlanModel
    private var getNationalityType : NationalityType
    private var getPlaceModeType : PlaceModeType
    private var getOnClickReviewCell : (ReviewModel) -> Void
    private var getOnClickWriteReview : (String) -> Void
    @Binding private var getModeType : ModeType
    init(
        setVisitPlaceModel : PlanModel,
        setNationalityType : NationalityType,
        setPlaceModeType : PlaceModeType,
        setModeType : Binding<ModeType>,
        onClickReviewCell : @escaping (ReviewModel) -> Void,
        onCallBackWriteReview : @escaping (String) -> Void
    ){
        self.getPlanModel = setVisitPlaceModel
        self.getNationalityType = setNationalityType
        self._getModeType = setModeType
        self.getOnClickReviewCell = onClickReviewCell
        self.getOnClickWriteReview = onCallBackWriteReview
        self.getPlaceModeType = setPlaceModeType
    }
    
  
    @EnvironmentObject private var scheduleVM : ScheduleVM
    @State private var selectedTabIndex = 0
    
    private func tabTitles() -> [String] {
        switch getPlaceModeType {
        case .MY :
            return ["메모", "문서", "리뷰"]
        case .OTHER :
            return ["리뷰"]
        }
    }

    
    @ViewBuilder
    private func tabHeader() -> some View {
        HStack(spacing: 0) {
            ForEach(Array(tabTitles().enumerated()), id: \.offset) { index, title in
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
        switch getPlaceModeType {
        case .MY :
            switch selectedTabIndex {
            case 0:
                VStack(){
                    Spacer(minLength: 32)

                    // 메모
                    EditableTextView(
                        setTitle: scheduleVM.planBindings.memo(for: getPlanModel.uid),
                        setHint: "클릭하여 해당 장소에 대해 메모가 필요한 경우 작성해주세요.",
                        setEditMode: $getModeType,
                        setAlignment: .vertical,
                        isMultiLine: true
                    ) {
                        // 클릭시 편집 모드 활성화
                        getModeType = .UPDATE
                    }
                    
                    Spacer(minLength: 32)
                }
            case 1:
                // 문서
                FileView(
                    visibleAddButton: .constant(getModeType == .CREATE || getModeType == .UPDATE),
                    fileList: scheduleVM.planBindings.files(for: getPlanModel.uid),
                    onFilesChanged: { updatedFileList in
                        print("🔍 Place에서 파일 변경: \(updatedFileList.count)개")
                    }
                )
            case 2:
                // 리뷰
                ReviewListView(
                    setPlaceModel: getPlanModel.placeModel,
                    setNationalityType: getNationalityType,
                    setOnClickCell: { clickedModel in
                        getOnClickReviewCell(clickedModel)
                    },
                    setOnClickWriteReview: {
                        getOnClickWriteReview(getPlanModel.placeModel.uid)
                    }
                )
            default:
                ReviewListView(
                    setPlaceModel: getPlanModel.placeModel,
                    setNationalityType: getNationalityType,
                    setOnClickCell: { clickedModel in
                        getOnClickReviewCell(clickedModel)
                    },
                    setOnClickWriteReview: {
                        getOnClickWriteReview(getPlanModel.placeModel.uid)
                    }
                )
            }
        case .OTHER :
            ReviewListView(
                setPlaceModel: getPlanModel.placeModel,
                setNationalityType: getNationalityType,
                setOnClickCell: { clickedModel in
                    getOnClickReviewCell(clickedModel)
                },
                setOnClickWriteReview: {
                    getOnClickWriteReview(getPlanModel.placeModel.uid)
                }
            )
        }
    }
    
    var body : some View {
        VStack(spacing: 0) {
            // 탭 헤더
            tabHeader()
            
            // 컨텐츠 영역
            tabContent()
        }
    }
}

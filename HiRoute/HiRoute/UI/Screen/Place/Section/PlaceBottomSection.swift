//
//  UserModel.swift
//  HiRoute
//
//  Created by Jupond on 7/26/25.
//
import SwiftUI

/// 장소 하단 섹션 (메모/문서/리뷰 탭 컨텐츠)
///
/// ## Event 패턴 적용 (Prop Drilling 제거)
/// [변경 전] 3개의 콜백 파라미터를 PlaceView로부터 전달받아 하위 뷰에 릴레이:
///   - onClickReviewCell: (ReviewModel) -> Void   → ReviewListView
///   - onCallBackWriteReview: () -> Void           → ReviewListView
///   - onFilesChanged: ([FileModel]) -> Void       → FileView
///
/// [변경 후] 콜백 파라미터 3개 모두 제거.
///   - ReviewListView: @EnvironmentObject placeVM로 직접 이벤트 발생
///   - FileView: scheduleVM.planBindings로 직접 바인딩
///   init 파라미터: 데이터 전달용 4개만 유지.
struct PlaceBottomSection : View {

    private var getPlanModel : PlanModel
    private var getNationalityType : NationalityType
    private var getPlaceModeType : PlaceModeType
    @Binding private var getModeType : ModeType
    private var onClickMemo : (() -> Void)?
    init(
        setPlanModel : PlanModel,
        setNationalityType : NationalityType,
        setPlaceModeType : PlaceModeType,
        setModeType : Binding<ModeType>,
        onClickMemo : (() -> Void)? = nil
    ){
        self.getPlanModel = setPlanModel
        self.getNationalityType = setNationalityType
        self._getModeType = setModeType
        self.getPlaceModeType = setPlaceModeType
        self.onClickMemo = onClickMemo
    }

    /// ScheduleVM: planBindings를 통해 메모/파일 데이터 바인딩에 접근
    @EnvironmentObject private var scheduleVM : ScheduleVM
    @EnvironmentObject private var placeVM : PlaceVM
    @State private var selectedTabIndex = 0

    private func tabTitles() -> [String] {
        switch getPlaceModeType {
        case .MY:
            return ["메모", "가이드", "문서", "리뷰"]
        case .OTHER:
            return ["가이드", "리뷰"]
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
        case .MY:
            // 메모(0) / 가이드(1) / 문서(2) / 리뷰(3)
            switch selectedTabIndex {
            case 0:
                memoTabView()
            case 1:
                guideTabView()
            case 2:
                fileTabView()
            default:
                reviewTabView()
            }
        case .OTHER:
            // 가이드(0) / 리뷰(1)
            switch selectedTabIndex {
            case 0:
                guideTabView()
            default:
                reviewTabView()
            }
        }
    }

    @ViewBuilder
    private func guideTabView() -> some View {
        if placeVM.isLoadingGuides {
            VStack {
                Spacer(minLength: 48)
                ProgressView()
                Spacer(minLength: 48)
            }
        } else if placeVM.guides.isEmpty {
            VStack {
                Spacer(minLength: 48)
                Text("등록된 가이드가 없습니다")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer(minLength: 48)
            }
        } else {
            GuideListView(guides: placeVM.guides)
        }
    }

    @ViewBuilder
    private func memoTabView() -> some View {
        VStack() {
            Spacer(minLength: 32)

            // 메모 (Text 표시 + 클릭 시 TopSheet 트리거)
            let memoText = getPlanModel.memo
            let isEmpty = memoText.isEmpty

            Text(isEmpty ? "클릭하여 해당 장소에 대해 메모가 필요한 경우 작성해주세요." : memoText)
                .font(.system(size: 16))
                .foregroundColor(isEmpty ? Color.getColour(.label_alternative) : Color.getColour(.label_normal))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                .contentShape(Rectangle())
                .onTapGesture {
                    if getModeType == .CREATE || getModeType == .UPDATE {
                        onClickMemo?()
                    }
                }

            Spacer(minLength: 32)
        }
    }

    @ViewBuilder
    private func fileTabView() -> some View {
        FileView(
            visibleAddButton: .constant({
                let shouldShow = getModeType == .CREATE || getModeType == .UPDATE
                print("🔍 FileView 버튼 가시성 - 모드: \(getModeType), 보이기: \(shouldShow)")
                return shouldShow
            }()),
            fileList: scheduleVM.planBindings.files(for: getPlanModel.uid),
            onFilesChanged: { _ in }
        )
    }

    @ViewBuilder
    private func reviewTabView() -> some View {
        ReviewListView(
            setPlaceModel: getPlanModel.placeModel,
            setNationalityType: getNationalityType
        )
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

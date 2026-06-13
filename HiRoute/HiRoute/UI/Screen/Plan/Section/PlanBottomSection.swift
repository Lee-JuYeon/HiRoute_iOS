//
//  StoreListView.swift
//  HiRoute
//
//  Created by Jupond on 8/3/25.
//
import SwiftUI


/// 일정 하단 섹션 (타임라인/지도 탭 컨텐츠)
///
/// ## Event 패턴 적용 (Prop Drilling 제거)
/// [변경 전] 4개의 콜백/바인딩 파라미터를 PlanView로부터 전달받음:
///   - onClickCell: (PlanModel) -> Void          → TimeLineListView
///   - onClickAnnotation: (PlanModel) -> Void    → PlanMapView
///   - setFileList: Binding<[FileModel]>          → 파일 관리용
///   - onFilesChanged: ([FileModel]) -> Void      → 파일 변경 콜백
///   이 콜백들은 모두 "Plan 선택" 또는 "파일 업데이트"라는 동일 동작이었으나
///   PlanView → PlanBottomSection → 하위뷰 순서로 릴레이되고 있었다.
///
/// [변경 후] 콜백 파라미터 4개 모두 제거.
///   - @EnvironmentObject scheduleVM 추가
///   - 셀/어노테이션 클릭: scheduleVM.planEvent.selectPlan(model) 직접 호출
///   - 파일 관리: scheduleVM.planBindings로 직접 바인딩
///   init 파라미터: setVisitPlaceList, setModeType 2개만 유지 (데이터 전달).
struct PlanBottomSection: View {
    /// 표시할 Plan 모델 리스트 (읽기 전용)
    private var getVisitPlaceList : [PlanModel]
    /// 현재 CRUD 모드 (READ/CREATE/UPDATE)
    private var getModeType : ModeType

    /// ScheduleVM에 @EnvironmentObject로 접근.
    /// - planEvent.selectPlan(): 셀/어노테이션 클릭 이벤트 처리
    /// - planBindings: 파일 데이터 바인딩 접근
    @EnvironmentObject private var scheduleVM : ScheduleVM
    @EnvironmentObject private var navigationVM : NavigationVM

    @Binding private var isReorderMode : Bool

    init(
        setVisitPlaceList : [PlanModel],
        setModeType : ModeType,
        setIsReorderMode : Binding<Bool> = .constant(false)
    ){
        self.getVisitPlaceList = setVisitPlaceList
        self.getModeType = setModeType
        self._isReorderMode = setIsReorderMode
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
                setIsReorderMode: $isReorderMode,
                setOnClickCell: { clickedVisitPlaceModel in
                    scheduleVM.planEvent.selectPlan(clickedVisitPlaceModel)
                    navigationVM.navigateTo(setDestination: .place)
                },
                setOnRequestPlaceSearch: {
                    navigationVM.navigateTo(setDestination: .placeSearch)
                },
                setOnMove: { from, to in
                    scheduleVM.updatePlanIndex(from: from, to: to)
                }
            )
            .tag(0)

            PlanMapView(
                setVisitPlaceList: getVisitPlaceList
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

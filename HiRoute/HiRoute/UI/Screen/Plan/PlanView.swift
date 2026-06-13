//
//  RouteView.swift
//  HiRoute
//
//  Created by Jupond on 7/5/25.
//
import SwiftUI


/// 일정 상세 화면 (제목, 메모, D-day, 타임라인/지도 탭)
///
/// ## Event 패턴 적용 후 변경 요약
///
/// ### 제거된 것들:
/// - @State private var currentPlanModel: PlanModel? = nil
///   → ScheduleVM.currentPlanModel(@Published)로 이동.
///   하위 뷰(PlanBottomSection → TimeLineListView/PlanMapView)에서
///   scheduleVM.planEvent.selectPlan()으로 직접 값 변경 가능.
///
/// - private func onCellClick(_ planModel: PlanModel)
/// - private func onAnnotaionClick(_ planModel: PlanModel)
///   → PlanEvent.selectPlan()으로 대체. 이 함수들은 단순히
///   currentPlanModel = planModel만 수행했으므로 불필요해짐.
///
/// - PlanBottomSection 호출 시 4개 콜백 파라미터 제거:
///   setFileList, onFilesChanged, onClickCell, onClickAnnotation
///   → PlanBottomSection(setVisitPlaceList:, setModeType:) 2개만 유지.
///
/// ### 유지된 것들 (뷰 로컬 상태):
/// - @State isShowOptionSheet, isShowTitleWriting, isShowMemoWriting 등
///   → PlanView에서만 사용되는 시트 트리거. 하위 뷰에서 접근 불필요.
///   → VM으로 옮길 이유 없음 (Prop Drilling 발생 안 함).
///
/// ### 화면 전환:
/// PlanEvent.selectPlan() + navigationVM.navigateTo(.place) 호출로
/// PlaceView로 전환. fullScreenCover 제거됨.
struct PlanView : View {

    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var navigationVM : NavigationVM
    /// ScheduleVM: currentPlanModel(@Published) + planEvent 보유.
    @EnvironmentObject private var scheduleVM : ScheduleVM
    @EnvironmentObject private var localVM : LocalVM
    @State private var isOfflineMode: Bool = false

    // 아래 @State들은 PlanView에서만 사용 (하위 뷰 접근 불필요 → VM 이동 불필요)
    @State private var isShowOptionSheet : Bool = false
    @State private var isShowTitleWriting : Bool = false
    @State private var isShowMemoWriting : Bool = false
    @State private var isShowDate : Bool = false
    @State private var showUnsavedAlert: Bool = false // 변경사항 알림
    @State private var isReorderMode: Bool = false

    private func dismissView() {
        presentationMode.wrappedValue.dismiss()
        // [2026-05-26] 일정탭 숨김 → planner로 복귀
        navigationVM.mainTabIndex = .planner
        navigationVM.navigateTo(setDestination: .main)
    }

    private func exit(forceExit: Bool = false) {
        switch navigationVM.currentModeType {
        case .CREATE:
            if scheduleVM.hasChanges && !forceExit {
                showUnsavedAlert = true
            } else {
                scheduleVM.cancelEditing()
                scheduleVM.selectedSchedule = nil
                dismissView()
            }

        case .UPDATE:
            if scheduleVM.hasChanges && !forceExit {
                showUnsavedAlert = true
            } else {
                scheduleVM.cancelEditing()
                if forceExit {
                    scheduleVM.selectedSchedule = nil
                    dismissView()
                } else {
                    navigationVM.currentModeType = .READ
                }
            }

        case .READ:
            scheduleVM.selectedSchedule = nil
            dismissView()
        }
    }
    
    private func back(){
        exit(forceExit: false)  // ✅ 일반 뒤로가기
    }
    
    private func showOptionSheet(){
        isShowOptionSheet = true
    }
    
    private func deleteSchedule(){
        isShowOptionSheet = false
        
        if let scheduleModel = scheduleVM.selectedSchedule {
            scheduleVM.deleteSchedule(scheduleUID: scheduleModel.uid)
            dismissView()
        }
    }
    
    private func editSchedule(){
        isShowOptionSheet = false
        navigationVM.currentModeType = .UPDATE
        
        // UPDATE 모드로 전환 시 편집 상태 초기화
        if let schedule = scheduleVM.selectedSchedule {
            scheduleVM.startEditing(schedule)
        }
    }
    
    private func saveSchedule(){
        switch navigationVM.currentModeType {
        case .CREATE:
            guard let schedule = scheduleVM.selectedSchedule else { return }
            scheduleVM.createSchedule(
                title: schedule.title,
                memo: schedule.memo,
                dDay: schedule.d_day,
                planList: schedule.planList
            ){ success in
                if success {
                    print("새 일정 생성 완료")
                }
                scheduleVM.selectedSchedule = nil
                dismissView()
            }
            return

        case .UPDATE:
            if scheduleVM.hasChanges {
                scheduleVM.finishEditing()
                print("✅ 저장 완료")
            } else {
                print("저장할 변경사항 없음")
            }
            scheduleVM.selectedSchedule = nil
            dismissView()
        case .READ:
            break
        }
    }
    
   
    var body: some View {
        VStack(alignment: HorizontalAlignment.leading){
            PlanOptionBar(
                onBack: {
                    back()
                },
                onSave: {
                    saveSchedule()
                },
                onEdit: {
                    showOptionSheet()
                },
                getModeType: navigationVM.currentModeType
            )
            
            // READ 타입일때만 일정 카운트 뷰 보여지게 하기 (update, create때는 굳이 필요 없어보임)
            if navigationVM.currentModeType == ModeType.READ {
                DdayCountingTextView(setDdayDate: scheduleVM.selectedSchedule?.d_day ?? Date())
                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))
            }
            
            EditableTextView(
                setTitle: Binding(
                    get: { scheduleVM.selectedSchedule?.title ?? "" },
                    set: { newTitle in
                        scheduleVM.updateUiTitle(newTitle) // 메모리 업데이트 (저장버튼 클릭시 db 업뎃)
                    }
                ),
                setHint: "클릭하여 일정 제목을 입력하세요",
                setEditMode: $navigationVM.currentModeType
            ) {
                switch navigationVM.currentModeType {
                case .READ:
                    break
                case .CREATE:
                    isShowTitleWriting = true
                case .UPDATE:
                    isShowTitleWriting = true
                }
            }
            
            EditableTextView(
                setTitle: Binding(
                    get: { scheduleVM.selectedSchedule?.memo ?? "" },
                    set: { newMemo in
                        scheduleVM.updateUiMemo(newMemo)
                    }
                ),
                setHint: "클릭하여 일정 내용을 입력하세요",
                setEditMode: $navigationVM.currentModeType,
                setAlignment: .vertical,
                isMultiLine: true,
                setTextSize: 18
            ){
                switch navigationVM.currentModeType {
                case .READ:
                    break
                case .CREATE:
                    isShowMemoWriting = true
                case .UPDATE:
                    isShowMemoWriting = true
                }
            }
            
            DateTextView(
                date: Binding(
                    get: { scheduleVM.selectedSchedule?.d_day ?? Date() },
                    set: { newD_day in
                        scheduleVM.updateUiDDay(newD_day)
                    }
                ),
                nationalityType: localVM.nationality,
                modeType: navigationVM.currentModeType,
                onDateChanged: {
                   
                }
            )
       
            // [Event 패턴 적용 후] 콜백 4개 제거, 데이터 2개만 전달.
            // PlanBottomSection 내부에서 @EnvironmentObject scheduleVM으로
            // planEvent.selectPlan() 직접 호출.
            if isReorderMode {
                HStack {
                    Spacer()
                    TextButton(
                        text: "완료",
                        textSize: 16,
                        textColour: Color.getColour(.label_strong),
                        callBackClick: {
                            isReorderMode = false
                        }
                    )
                }
                .padding(.horizontal, 16)
            }

            PlanBottomSection(
                setVisitPlaceList: scheduleVM.selectedSchedule?.planList ?? [],
                setModeType: navigationVM.currentModeType,
                setIsReorderMode: $isReorderMode
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.getColour(.background_yellow_white))
        .bottomSheet(isOpen: $showUnsavedAlert, setContent: {
            VStack(alignment: .center, spacing: 16) {
                VStack(spacing: 4) {
                    Text("변경사항이 있습니다")
                        .font(.system(size: 16))
                        .foregroundColor(Color.getColour(.label_strong))
                    Text("저장하지 않은 변경사항은 손실됩니다.")
                        .font(.system(size: 14))
                        .foregroundColor(Color.getColour(.label_alternative))
                }
                .multilineTextAlignment(.center)
                .padding(.top, 20)

                HStack(spacing: 12) {
                    StrokeTextButton(text: "나가기") {
                        showUnsavedAlert = false
                        switch navigationVM.currentModeType {
                        case .CREATE, .UPDATE:
                            scheduleVM.cancelEditing()
                            scheduleVM.selectedSchedule = nil
                            dismissView()
                        case .READ:
                            scheduleVM.selectedSchedule = nil
                            dismissView()
                        }
                    }
                    .frame(maxWidth: .infinity)

                    FillTextButton(text: "저장") {
                        showUnsavedAlert = false
                        saveSchedule()
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
        })
        .bottomSheet(isOpen: $isShowOptionSheet) {
            SheetPlanOptionView(
                setOnClickDeleteOption: {
                    deleteSchedule()
                },
                setOnClickEditOption: {
                    editSchedule()
                }
            )
        }
        .topSheet(isOpen: $isShowTitleWriting, setContent: {
            SheetTextFieldView(
                setHint: "일정 제목을 입력하세요",
                setText: Binding(
                    get: { scheduleVM.selectedSchedule?.title ?? "" },
                    set: { newTitle in
                        scheduleVM.updateUiTitle(newTitle) // 메모리 업데이트 (저장버튼 클릭시 db 업뎃)
                    }
                ),
                setToolBarTitle: "일정 제목",
                callBackCancel: {
                    // 취소 버튼 추가
                    scheduleVM.cancelEditing()
                    isShowTitleWriting = false
                    
                    // 약간의 딜레이 후 키보드 해제
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        hideKeyboard()
                    }
                },
                callBackSave: {
                    // 저장 로직
                    isShowTitleWriting = false
                    
                    // 약간의 딜레이 후 키보드 해제
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        hideKeyboard()
                    }
                }
            )
        })
        .topSheet(isOpen: $isShowMemoWriting, setContent: {
            SheetTextFieldView(
                setHint: "일정 내용을 입력하세요",
                setText: Binding(
                    get: { scheduleVM.selectedSchedule?.memo ?? "" },
                    set: { newMemo in
                        scheduleVM.updateUiMemo(newMemo)
                    }
                ),
                setToolBarTitle: "일정 내용",
                callBackCancel: {
                    // 취소 버튼 추가
                    scheduleVM.cancelEditing()
                    isShowMemoWriting = false
                    
                    // 약간의 딜레이 후 키보드 해제
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        hideKeyboard()
                    }
                },
                callBackSave: {
                    // 저장 로직
                    isShowMemoWriting = false
                    
                    // 약간의 딜레이 후 키보드 해제
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        hideKeyboard()
                    }
                }
            )
        })
        .onAppear {
            navigationVM.currentPlaceModeType = .MY
            switch navigationVM.currentModeType {
            case .READ:
                print("READ 모드입니다.")
            case .CREATE:
                if let schedule = scheduleVM.selectedSchedule {
                    scheduleVM.startEditing(schedule)
                }
                print("CREATE 모드입니다.")
            case .UPDATE:
                if let schedule = scheduleVM.selectedSchedule {
                    scheduleVM.startEditing(schedule)
                }
                print("UPDATE 모드입니다.")
            }
        }
        .onDisappear {
        }
    }
}

//
//  RouteView.swift
//  HiRoute
//
//  Created by Jupond on 7/5/25.
//
import SwiftUI


struct PlanView : View {
    
    @State private var getModeType : ModeType
    private var getScheduleModel : ScheduleModel

    init(
        setModeType : ModeType,
        setScheduleModel: ScheduleModel
    ){
        self._getModeType = State(initialValue: setModeType)
        self.getScheduleModel = setScheduleModel
    }
    
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var scheduleVM : ScheduleVM
    @EnvironmentObject private var localVM : LocalVM
    
    @State private var placeModeType = PlaceModeType.MY
    @State private var isOfflineMode: Bool = false
    
    @State private var isShowOptionSheet : Bool = false
    @State private var isShowTitleWriting : Bool = false
    @State private var isShowMemoWriting : Bool = false
    @State private var isShowDate : Bool = false
    @State private var showUnsavedAlert: Bool = false // 변경사항 알림
    
    @State private var currentPlanModel : PlanModel? = nil
    
    // 키보드 해제 헬퍼 함수
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func exit(forceExit: Bool = false) {
        switch getModeType {
        case .CREATE:
            if scheduleVM.hasChanges && !forceExit {
                showUnsavedAlert = true
            } else {
                scheduleVM.cancelEditing()
                scheduleVM.selectedSchedule = nil
                presentationMode.wrappedValue.dismiss()
            }
            
        case .UPDATE:
            if scheduleVM.hasChanges && !forceExit {
                showUnsavedAlert = true
            } else {
                scheduleVM.cancelEditing()
                if forceExit {
                    // ✅ 강제 종료시에는 완전히 나가기
                    scheduleVM.selectedSchedule = nil
                    presentationMode.wrappedValue.dismiss()
                } else {
                    // ✅ 일반 백버튼시에는 READ 모드로만 전환
                    getModeType = .READ
                }
            }
            
        case .READ:
            scheduleVM.selectedSchedule = nil
            presentationMode.wrappedValue.dismiss()
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
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func onCellClick(_ planModel : PlanModel){
       currentPlanModel = planModel
    }
    
    private func onAnnotaionClick(_ planModel : PlanModel){
        currentPlanModel = planModel
    }
    
    private func editSchedule(){
        isShowOptionSheet = false
        getModeType = .UPDATE
        
        // UPDATE 모드로 전환 시 편집 상태 초기화
        if let schedule = scheduleVM.selectedSchedule {
            scheduleVM.startEditing(schedule)
        }
    }
    
    private func saveSchedule(){
        switch getModeType {
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
                presentationMode.wrappedValue.dismiss()
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
            presentationMode.wrappedValue.dismiss()
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
                getModeType: getModeType
            )
            
            // READ 타입일때만 일정 카운트 뷰 보여지게 하기 (update, create때는 굳이 필요 없어보임)
            if getModeType == ModeType.READ {
                DdayCountingTextView(setDdayDate: getScheduleModel.d_day)
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
                setEditMode: $getModeType
            ) {
                switch getModeType {
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
                setEditMode: $getModeType,
                setAlignment: .vertical,
                isMultiLine: true,
                setTextSize: 18
            ){
                switch getModeType {
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
                modeType: getModeType,
                onDateChanged: {
                   
                }
            )
       
            PlanBottomSection(
                setVisitPlaceList: scheduleVM.selectedSchedule?.planList ?? [],
                setModeType: getModeType,
                onClickCell: { clickedPlanModel in
                    onCellClick(clickedPlanModel)
                },
                onClickAnnotation: { clickedPlanModel in
                    onAnnotaionClick(clickedPlanModel)
                }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.getColour(.background_yellow_white))
        .bottomSheet(isOpen: $showUnsavedAlert, setContent: {
            VStack(alignment: HorizontalAlignment.center){
                Text("변경사항이 있습니다")
                Text("저장하시겠습니까?")
                Text("저장하지 않은 변경사항은 손실됩니다.")
                HStack(alignment: VerticalAlignment.top){
                    Button("저장") {
                        showUnsavedAlert = false
                                        
                        // 실제 저장 수행
                        if scheduleVM.hasChanges {
                            scheduleVM.finishEditing()  // 저장
                            print("바텀시트에서 저장 완료")
                        }
                        
                        // 저장 후 종료
                        scheduleVM.selectedSchedule = nil
                        presentationMode.wrappedValue.dismiss()
                    }
                    
                    Spacer()
                    
                    Button("나가기") {
                        // 1. bottomSheet 먼저 닫기
                        showUnsavedAlert = false
                        
                        // 2. 모든 케이스에서 변경사항 취소하고 완전히 나가기
                        switch getModeType {
                        case .CREATE:
                            scheduleVM.cancelEditing()
                            scheduleVM.selectedSchedule = nil
                            presentationMode.wrappedValue.dismiss()
                            
                        case .UPDATE:
                            scheduleVM.cancelEditing()
                            scheduleVM.selectedSchedule = nil
                            presentationMode.wrappedValue.dismiss()
                            
                        case .READ:
                            scheduleVM.selectedSchedule = nil
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
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
        .fullScreenCover(item: $currentPlanModel) { planModel in
            PlaceView(
                setPlanModel: planModel,
                setPlaceModeType : placeModeType
            )
        }
        .onAppear {
            switch getModeType {
            case .READ:
                scheduleVM.selectedSchedule = getScheduleModel
                print("READ 모드입니다.")
            case .CREATE:
                // 아무것도 하지 않음 (이미 ScheduleView에서 처리됨)
                print("CREATE 모드입니다.")
                break
                
            case .UPDATE:
                scheduleVM.startEditing(getScheduleModel)
                print("UPDATE 모드입니다.")
            }
        }
        .onDisappear {
            // 메모리 정리만 (자동 저장 제거)
            if (scheduleVM.selectedSchedule != nil){
                scheduleVM.selectedSchedule = nil
            }
            
            if scheduleVM.hasChanges {
                   scheduleVM.finishEditing()
               } else {
                   scheduleVM.cancelEditing()
               }
               scheduleVM.clearSelection()  // 메모리 정리
        }
    }
}

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
    
    private func handleExit(forceExit: Bool = false) {
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
    
    private func handleBackButton(){
        handleExit(forceExit: false)  // ✅ 일반 뒤로가기
    }
    
    private func handleOptionButton(){
        isShowOptionSheet = true
    }
    
    private func handleDeleteSchedule(){
        isShowOptionSheet = false
        
        if let scheduleModel = scheduleVM.selectedSchedule {
            scheduleVM.deleteSchedule(scheduleUID: scheduleModel.uid)
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func handleCellClick(_ planModel : PlanModel){
        scheduleVM.selectedPlanModel = planModel
    }
    
    private func handleAnnotationClick(_ planModel : PlanModel){
        // PlanVM을 통한 장소 선택
        scheduleVM.selectedPlanModel = planModel
    }
    
    private func handleEditSchedule(){
        isShowOptionSheet = false
        getModeType = .UPDATE
        
        // UPDATE 모드로 전환 시 편집 상태 초기화
        if let schedule = scheduleVM.selectedSchedule {
            scheduleVM.startEditing(schedule)
        }
    }
    
    private func handleSaveSchedule(){
        switch getModeType {
        case .CREATE:
            scheduleVM.createSchedule(
                title: scheduleVM.scheduleTitle,
                memo: scheduleVM.scheduleMemo,
                dDay: scheduleVM.scheduleDday
            ){ success in
                if success {
                    print("새 일정 생성 완료")
                }
                scheduleVM.selectedSchedule = nil
                presentationMode.wrappedValue.dismiss()
            }
            return
            
        case .UPDATE:
            let originalCount = getScheduleModel.planList.count
            let currentCount = scheduleVM.selectedSchedule?.planList.count ?? 0
            let hasChanges = scheduleVM.hasChanges
            
            print("=== 저장 시도 ===")
            print("원본 Plan: \(originalCount)개")
            print("현재 Plan: \(currentCount)개")
            print("변경사항: \(hasChanges)")
            print("================")
            
            // Plan 개수가 다르거나 기본 변경사항이 있으면 저장
            if hasChanges || originalCount != currentCount {
                scheduleVM.updateScheduleInfo(
                    uid: scheduleVM.selectedSchedule!.uid,
                    title: scheduleVM.scheduleTitle,
                    memo: scheduleVM.scheduleMemo,
                    dDay: scheduleVM.scheduleDday
                ) { success in
                    print("✅ 저장 완료: \(success)")
                    scheduleVM.selectedSchedule = nil
                    presentationMode.wrappedValue.dismiss()
                }
            } else {
                print("저장할 변경사항 없음")
                scheduleVM.selectedSchedule = nil
                presentationMode.wrappedValue.dismiss()
            }
            return
                   
        case .READ:
            break
        }
    }
    
    @ViewBuilder
    private func optionBar() -> some View {
        HStack(){
            ImageButton(imageURL : "icon_back",imageSize: 30) {
                handleBackButton()
            }
            
            Spacer()
          
            switch getModeType {
            case .READ:
                TextButton(
                    text: "편집",
                    textSize: 16,
                    textColour: Color.blue
                ) {
                    handleOptionButton()
                }
            case .CREATE:
                TextButton(
                    text: "저장",
                    textSize: 16,
                    textColour: Color.blue
                ) {
                    handleSaveSchedule()
                }
            case .UPDATE:
                TextButton(
                    text: "저장",
                    textSize: 16,
                    textColour: Color.blue
                ) {
                    handleSaveSchedule()
                }
            }
        }
        .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
    }
    
 
    var body: some View {
        VStack(alignment: HorizontalAlignment.leading){
            optionBar()
            
            // READ 타입일때만 일정 카운트 뷰 보여지게 하기 (update, create때는 굳이 필요 없어보임)
            if getModeType == ModeType.READ {
                DdayCountingTextView(setDdayDate: getScheduleModel.d_day)
                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 8, trailing: 16))
            }
            
            EditableTextView(
                setTitle: $scheduleVM.scheduleTitle,
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
                setTitle: $scheduleVM.scheduleMemo,
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
                date: $scheduleVM.scheduleDday,
                nationalityType: localVM.nationality,
                modeType: getModeType,
                onDateChanged: {
                   
                }
            )
       
            PlanBottomSection(
                setVisitPlaceList: scheduleVM.selectedSchedule?.planList ?? [],
                setModeType: getModeType,
                onClickCell: { clickedVisitPlaceModel in
                    handleCellClick(clickedVisitPlaceModel)
                },
                onClickAnnotation: { selectedVisitPlaceModel in
                    handleAnnotationClick(selectedVisitPlaceModel)
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
//                        // ✅ 1. bottomSheet 먼저 닫기
//                        showUnsavedAlert = false
//                        
//                        // ✅ 2. 모드별 저장 처리
//                        switch getModeType {
//                        case .CREATE:
//                            scheduleVM.createSchedule(
//                                title: scheduleVM.scheduleTitle,
//                                memo: scheduleVM.scheduleMemo,
//                                dDay: scheduleVM.scheduleDday
//                            ) { success in
//                                if success {
//                                    print("새 일정 생성 완료")
//                                }
//                                scheduleVM.selectedSchedule = nil
//                                presentationMode.wrappedValue.dismiss()
//                            }
//                            
//                        case .UPDATE:
//                            _ = scheduleVM.finishEditingIfChanged { success in
//                                if success {
//                                    print("변경사항 저장 완료")
//                                } else {
//                                    print("저장할 변경사항 없음")
//                                }
//                                scheduleVM.selectedSchedule = nil
//                                presentationMode.wrappedValue.dismiss()
//                            }
//                            
//                        case .READ:
//                            break
//                        }
                        showUnsavedAlert = false
                        handleExit(forceExit: true)  // ✅ 강제 종료
                    }
                    
                    Spacer()
                    
                    Button("나가기") {
                        // ✅ 1. bottomSheet 먼저 닫기
                        showUnsavedAlert = false
                        
                        // ✅ 2. 모든 케이스에서 변경사항 취소하고 완전히 나가기
                        switch getModeType {
                        case .CREATE:
                            scheduleVM.cancelEditing()
                            scheduleVM.selectedSchedule = nil
                            presentationMode.wrappedValue.dismiss()
                            
                        case .UPDATE:
                            scheduleVM.cancelEditing()           // ✅ 변경사항 취소
                            scheduleVM.selectedSchedule = nil    // ✅ 선택 해제
                            presentationMode.wrappedValue.dismiss()  // ✅ 화면 닫기
                            
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
                    handleDeleteSchedule()
                },
                setOnClickEditOption: {
                    handleEditSchedule()
                }
            )
        }
        .topSheet(isOpen: $isShowTitleWriting, setContent: {
            SheetTextFieldView(
                setHint: "일정 제목을 입력하세요",
                setText: $scheduleVM.scheduleTitle,
                setToolBarTitle: "일정 제목",
                callBackCancel: {
                    // 취소 버튼 추가
                    scheduleVM.cancelEditing()
                    isShowTitleWriting = false
                },
                callBackSave: {
                    // 저장 로직
                    isShowTitleWriting = false
                }
            )
        })
        .topSheet(isOpen: $isShowMemoWriting, setContent: {
            SheetTextFieldView(
                setHint: "일정 내용을 입력하세요",
                setText: $scheduleVM.scheduleMemo,
                setToolBarTitle: "일정 내용",
                callBackCancel: {
                    // 취소 버튼 추가
                    scheduleVM.cancelEditing()
                    isShowMemoWriting = false
                },
                callBackSave: {
                    // 저장 로직
                    isShowMemoWriting = false
                }
            )
        })
        .fullScreenCover(item: $scheduleVM.selectedPlanModel) { planModel in
            PlaceView(
                setPlanModel: planModel,
                setPlaceModeType : placeModeType
            )
        }
        .onAppear {
            switch getModeType {
            case .READ:
                scheduleVM.selectedSchedule = getScheduleModel
                
                scheduleVM.scheduleTitle = getScheduleModel.title
                scheduleVM.scheduleMemo = getScheduleModel.memo
                scheduleVM.scheduleDday = getScheduleModel.d_day
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
            // 편집 중이고 변경사항이 있으면 로컬 저장
//            if scheduleVM.isEditing && scheduleVM.hasChanges {
//                scheduleVM.finishEditing()
//            } else if scheduleVM.isEditing {
//                scheduleVM.cancelEditing()
//            }
            
            // ✅ 수정: 메모리 안전한 클리어 처리
//            scheduleVM.clearSelection()
//            planVM.clearSelection()
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

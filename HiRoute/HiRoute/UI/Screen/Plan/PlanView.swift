//
//  RouteView.swift
//  HiRoute
//
//  Created by Jupond on 7/5/25.
//
import SwiftUI


struct PlanView : View {
    
    private var getModeType : ModeType
    private var getScheduleModel : ScheduleModel
    
    init(
        setModeType : ModeType,
        setScheduleModel: ScheduleModel
    ){
        self.getModeType = setModeType
        self.getScheduleModel = setScheduleModel
    }
    
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var scheduleVM : ScheduleVM
    @EnvironmentObject private var planVM: PlanVM
    @EnvironmentObject private var localVM : LocalVM
    
    @State private var placeModeType = PlaceModeType.MY
    @State private var isOfflineMode: Bool = false
    
    @State private var isShowOptionSheet : Bool = false
    @State private var isShowTitleWriting : Bool = false
    @State private var isShowMemoWriting : Bool = false
    @State private var isShowDate : Bool = false
    @State private var showUnsavedAlert: Bool = false // ✅ 변경사항 알림
    
    private func handleBackButton(){
        if getModeType != .READ && scheduleVM.hasChanges {
            showUnsavedAlert = true // ✅ 변경사항 확인 알림
        } else {
            scheduleVM.selectedSchedule = nil
            presentationMode.wrappedValue.dismiss()
        }
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
        planVM.currentPlan = planModel
    }
    
    private func handleAnnotationClick(_ planModel : PlanModel){
        // PlanVM을 통한 장소 선택
        planVM.currentPlan = planModel
    }
    
    private func handleEditSchedule(){
        isShowOptionSheet = false
    }
    
    private func handleSaveSchedule(){
        switch getModeType {
        case .CREATE:
            // ✅ CREATE 모드: 새 스케줄 생성
            scheduleVM.createSchedule(
                title: scheduleVM.planTitle,
                memo: scheduleVM.planMemo,
                dDay: scheduleVM.planDDay
            ){ success in
                if success {
                    print("새 일정 생성 완료")
                }
                scheduleVM.selectedSchedule = nil
                presentationMode.wrappedValue.dismiss()
            }
            return // ✅ 여기서 리턴 (아래 코드 실행 안함)
            print("새 일정 생성 완료")
            
        case .UPDATE:
            // ✅ UPDATE 모드: 기존 스케줄 수정
            if scheduleVM.finishEditingIfChanged() {
                print("변경사항 저장 완료")
            } else {
                print("저장할 변경사항 없음")
            }
            
        case .READ:
            // ✅ READ 모드: 저장 버튼 없음 (이 케이스는 실행되지 않음)
            break
        }
        
        scheduleVM.selectedSchedule = nil
        presentationMode.wrappedValue.dismiss()
    }
    
    @ViewBuilder
    private func optionBar() -> some View {
        HStack(){
            ImageButton(imageURL : "icon_back",imageSize: 30) {
                handleBackButton()
            }
            
            Spacer()
          
            if getModeType == ModeType.READ {
                ImageButton(imageURL: "icon_setting", imageSize: 30) {
                    handleOptionButton()
                }
            } else {
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
                setTitle: $scheduleVM.planTitle,
                setHint: "클릭하여 일정 제목을 입력하세요"
            ) {
                isShowTitleWriting = true
            }.padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            
            EditableTextView(
                setTitle: $scheduleVM.planMemo,
                setHint: "클릭하여 일정 내용을 입력하세요",
                callBackClick: {
                    isShowMemoWriting = true
                },
                setAlignment: .vertical,
                isMultiLine: true,
                setTextSize: 18
            ).padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            
            DateTextView(
                date: $scheduleVM.planDDay,
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
                    Button("저장 ") {
                        switch getModeType {
                        case .CREATE:
                            scheduleVM.createSchedule(
                                title: scheduleVM.planTitle,
                                memo: scheduleVM.planMemo,
                                dDay: scheduleVM.planDDay
                            ){ result in
                                
                                
                            }
                        case .UPDATE:
                            if scheduleVM.finishEditingIfChanged() {
                                print("변경사항 저장 완료")
                            }
                        case .READ:
                            break
                        }
                        scheduleVM.selectedSchedule = nil
                        presentationMode.wrappedValue.dismiss()
                    }
                    Spacer()
                    Button("나가기") {
                        scheduleVM.cancelEditing()
                        scheduleVM.selectedSchedule = nil
                        presentationMode.wrappedValue.dismiss()
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
                setText: $scheduleVM.planTitle,
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
                setText: $scheduleVM.planMemo,
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
        .fullScreenCover(item: $planVM.currentPlan) { planModel in
            PlaceView(
                setPlanModel: planModel,
                setPlaceModeType : placeModeType
            )
        }
        .onAppear {
            switch getModeType {
            case .READ:
                scheduleVM.selectedSchedule = getScheduleModel
                
            case .CREATE:
                // 아무것도 하지 않음 (이미 ScheduleView에서 처리됨)
                break
                
            case .UPDATE:
                scheduleVM.startEditing(getScheduleModel)
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
            if getModeType == .READ {
                scheduleVM.selectedSchedule = nil
            }
        }
    }
}

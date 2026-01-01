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
    
    private func handleBackButton(){
        // 메모리 안전한 클리어 처리
//        scheduleVM.clearSelection()
        scheduleVM.selectedSchedule = nil
//        planVM.clearSelection()
        presentationMode.wrappedValue.dismiss()
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
                setTitle: scheduleVM.scheduleBindings.title,
                setHint: "클릭하여 일정 제목을 입력하세요"
            ) {
                isShowTitleWriting = true
            }.padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            
            EditableTextView(
                setTitle: scheduleVM.scheduleBindings.memo,
                setHint: "클릭하여 일정 내용을 입력하세요",
                callBackClick: {
                    isShowMemoWriting = true
                },
                setAlignment: .vertical,
                isMultiLine: true,
                setTextSize: 18
            ).padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            
            DateTextView(
                date: scheduleVM.scheduleBindings.dDay,
                nationalityType: localVM.nationality,
                modeType: getModeType
            )
                        
       
            PlanBottomSection(
                setVisitPlaceList: getScheduleModel.planList,
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
                setText: scheduleVM.scheduleBindings.title,
                setToolBarTitle: "일정 제목",
                callBackCancel: {
                    // 취소 버튼 추가
//                    scheduleVM.cancelEditing()
                    isShowTitleWriting = false
                },
                callBackSave: {
                    // 저장 로직
//                    scheduleVM.finishEditing()
                    isShowTitleWriting = false
                }
            )
        })
        .topSheet(isOpen: $isShowMemoWriting, setContent: {
            SheetTextFieldView(
                setHint: "일정 내용을 입력하세요",
                setText: scheduleVM.scheduleBindings.memo,
                setToolBarTitle: "일정 내용",
                callBackCancel: {
                    // 취소 버튼 추가
//                    scheduleVM.cancelEditing()
                    isShowMemoWriting = false
                },
                callBackSave: {
                    // 저장 로직
//                    scheduleVM.finishEditing()
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
            // ✅ 추가: 계획 데이터 로드
            scheduleVM.selectSchedule(getScheduleModel)

//            planVM.loadPlan(for: getScheduleModel)
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
        }
    }
}

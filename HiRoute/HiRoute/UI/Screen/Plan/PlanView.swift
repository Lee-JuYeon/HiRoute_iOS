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
    @EnvironmentObject private var 이게 : ScheduleVM
    @EnvironmentObject private var planVM: PlanVM
    @EnvironmentObject private var localVM : LocalVM

    @State private var isShowOptionSheet = false
    @State private var placeModeType = PlaceModeType.MY
    @State private var isOfflineMode: Bool = false
    
    private func handleBackButton(){
        // 메모리 안전한 클리어 처리
        scheduleVM.clearSelection()
        planVM.clearSelection()
        presentationMode.wrappedValue.dismiss()
    }
    
    private func handleOptionButton(){
        isShowOptionSheet = true
    }
    
    private func handleDeleteSchedule(){
        isShowOptionSheet = false
        
        if let scheduleModel = scheduleVM.selectedSchedule {
            if isOfflineMode {
                scheduleVM.markForDeletion(scheduleUID)
            } else {
                scheduleVM.delete(scheduleUID: scheduleModel.uid)
            }
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func handleCellClick(_ visitPlaceModel : VisitPlaceModel){
        planVM.selectVisitPlace(visitPlaceModel)
    }
    
    private func handleAnnotationClick(_ visitPlaceModel : VisitPlaceModel){
        // PlanVM을 통한 장소 선택
        planVM.selectVisitPlace(visitPlaceModel)
    }
    
    private func handleEditSchedule(){
        isShowOptionSheet = false
        scheduleVM.setEditMode(true)
        print("일정 수정 확정")
    }
    
    // ✅ 추가: 네트워크 상태 확인
    private func checkNetworkStatus() {
        isOfflineMode = !NetworkMonitor.shared.isConnected
    }
    
    var body: some View {
        VStack(alignment: HorizontalAlignment.leading){
            PlanToolBar(
                setOnClickBack: {
                   handleBackButton()
                },
                setOnClickSettings: {
                    handleOptionButton()
                }
            )
            
            PlanTopSection(
                setNationalityType: localVM.nationality,
                setModeType: getModeType,
            )
          
            PlanBottomSection(
                setVisitPlaceList: getScheduleModel.visitPlaceList,
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
        .fullScreenCover(item: $planVM.selectedVisitPlace) { visitPlaceModel in
            PlaceView(
                setVisitPlaceModel: visitPlaceModel,
                setPlaceModeType : placeModeType
            )
        }
        .onAppear {
            checkNetworkStatus()
            // ✅ 추가: 계획 데이터 로드
            planVM.loadPlan(for: getScheduleModel)
        }
        .onDisappear {
            // ✅ 수정: 메모리 안전한 클리어 처리
            scheduleVM.clearSelection()
            planVM.clearSelection()
        }
    }
}

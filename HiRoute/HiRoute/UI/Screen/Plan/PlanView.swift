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
    @EnvironmentObject private var scheduleVM: ScheduleViewModel
    @EnvironmentObject private var localVM : LocalVM

    @State private var isShowOptionSheet = false
    @State private var placeModeType = PlaceModeType.MY
    
    private func handleBackButton(){
        scheduleVM.clearAllModels()
        presentationMode.wrappedValue.dismiss()
    }
    
    private func handleOptionButton(){
        isShowOptionSheet = true
    }
    
    private func handleDeleteSchedule(){
        isShowOptionSheet = false
        
        if let scheduleUID = scheduleVM.selectedSchedule?.uid {
            scheduleVM.deleteSchedule(scheduleUID: scheduleUID)
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func handleCellClick(_ visitPlaceModel : VisitPlaceModel){
        scheduleVM.selectVisitPlace(visitPlaceModel)
    }
    
    private func handleAnnotationClick(_ visitPlaceModel : VisitPlaceModel){
        print("클릭된 핀 : \(visitPlaceModel.placeModel.title)")
        scheduleVM.selectPlace(visitPlaceModel.placeModel)
    }
    
    private func handleEditSchedule(){
        isShowOptionSheet = false
        print("일정 수정 확정")
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
        .fullScreenCover(item: $scheduleVM.selectedVisitPlace) { visitPlaceModel in
            PlaceView(
                setVisitPlaceModel: visitPlaceModel,
                setPlaceModeType : placeModeType
            )
        }
        .onDisappear {
            scheduleVM.clearAllModels()
        }
    }
}

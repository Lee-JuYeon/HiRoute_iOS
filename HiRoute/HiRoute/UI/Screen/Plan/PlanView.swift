//
//  RouteView.swift
//  HiRoute
//
//  Created by Jupond on 7/5/25.
//
import SwiftUI

struct PlanView : View {
    
    private var getModeType : ModeType
    private var getNationalityType : NationalityType
 
    init(
        setModeType : ModeType,
        setNationalityType : NationalityType
    ){
        self.getModeType = setModeType
        self.getNationalityType = setNationalityType
    }
   
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var scheduleVM: ScheduleViewModel

    @State private var isShowOptionSheet = false
    @State private var isShowPlaceDetailView = false

    
    var body: some View {
        VStack(alignment: HorizontalAlignment.leading){
            PlanToolBar(
                setOnClickBack: {
                    scheduleVM.clearAllModels()
                    presentationMode.wrappedValue.dismiss()
                },
                setOnClickSettings: {
                    isShowOptionSheet = true
                }
            )
            
            PlanTopSection(
                setNationalityType: getNationalityType,
                setModeType : getModeType
            )
          
            if let selectedSchedule = scheduleVM.selectedSchedule {
                PlanBottomSection(
                    setVisitPlaceList: selectedSchedule.visitPlaceList,
                    onClickCell: { clickedVisitPlaceModel in
                        scheduleVM.selectVisitPlace(clickedVisitPlaceModel)
                    },
                    onClickAnnotation: { selectedVisitPlaceModel in
                        print("클릭된 핀 : \(selectedVisitPlaceModel.placeModel.title)")
//                        scheduleVM.selectPlace(selectedVisitPlaceModel.placeModel)
                    }
                )
            } else {
                // ✅ 선택된 스케줄이 없을 때 처리
                Text("스케줄을 불러올 수 없습니다.")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color.getColour(.background_yellow_white))
        .bottomSheet(isOpen: $isShowOptionSheet) {
            SheetPlanOptionView(
                setOnClickDeleteOption: {
                    isShowOptionSheet = false
                    if let scheduleUID = scheduleVM.selectedSchedule?.uid {
                        // ✅ ScheduleViewModel 메소드 사용
                        scheduleVM.deleteSchedule(scheduleUID: scheduleUID)
                        presentationMode.wrappedValue.dismiss()
                    }
                },
                setOnClickEditOption: {
                    isShowOptionSheet = false
                    print("일정 수정 확정")
                }
            )
        }
        .fullScreenCover(item: $scheduleVM.selectedVisitPlace) { visitPlaceModel in
            PlaceView(
                setPlaceModel: visitPlaceModel.placeModel,
                setNationalityType: getNationalityType
            )
        }
        .onDisappear {
            scheduleVM.clearAllModels()
        }
    }
}

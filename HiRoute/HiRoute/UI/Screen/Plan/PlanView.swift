//
//  RouteView.swift
//  HiRoute
//
//  Created by Jupond on 7/5/25.
//
import SwiftUI

struct PlanView : View {
    
    private var getScheduleModel : ScheduleModel
    private var getViewType : PlanViewType
    private var getNationalityType : NationalityType
    @Environment(\.presentationMode) var presentationMode
    init(
        setScheduleModel : ScheduleModel,
        setViewType : PlanViewType,
        setNationalityType : NationalityType
    ){
        self.getScheduleModel = setScheduleModel
        self.getViewType = setViewType
        self.getNationalityType = setNationalityType
    }

    
    @State private var memoText : String = "토마토 크림파스타가 맛있다 해서 가볼 예정. 성수역 3번 출구에서 도보 5분 거리. 내부는 조용하고 자리 넓다 함. 주차는 불가하고 애견동반 가능한 매장. 노키즈존이라 안시끄러울듯토마토 크림파스타가 맛있다 해서 가볼 예정. 성수역 3번 출구에서 도보 5분 거리. 내부는 조용하고 자리 넓다 함. 주차는 불가하고 애견동반 가능한 매장. 노키즈존이라 안시끄러울듯토마토 크림파스타가 맛있다 해서 가볼 예정. 성수역 3번 출구에서 도보 5분 거리. 내부는 조용하고 자리 넓다 함. 주차는 불가하고 애견동반 가능한 매장. 노키즈존이라 안시끄러울듯"
    
    @State private var isShowOptionSheet = false
    @State private var isShowPlaceDetailView = false
    @State private var selectedVisitPlaceModel : VisitPlaceModel?
    
    var body: some View {
        VStack(alignment: HorizontalAlignment.leading){
            PlanToolBar(
                setOnClickBack: {
                    presentationMode.wrappedValue.dismiss()
                },
                setOnClickSettings: {
                    isShowOptionSheet = true
                }
            )
          
            PlanTopSection(
                setScheduleModel: getScheduleModel,
                setNationalityType: getNationalityType,
                setMemoText: $memoText
            )
            
            PlanBottomSection(
                setVisitPlaceList: getScheduleModel.visitPlaceList,
                onClickCell: { clickedVisitPlaceModel in
                    isShowPlaceDetailView = true
                    selectedVisitPlaceModel = clickedVisitPlaceModel
                    print("placeview 보여주기1")
                },
                onClickAnnotation: { selectedVisitPlaceModel in
                    print("클릭된 핀 : \(selectedVisitPlaceModel.placeModel.title)")
                }
            )
        }
        .background(Color.getColour(.background_yellow_white))
        .bottomSheet(isOpen: $isShowOptionSheet) {
            SheetPlanOptionView(
                setOnClickDeleteOption: {
                    isShowOptionSheet = false
                    print("일정 삭제 확정")
                },
                setOnClickEditOption: {
                    isShowOptionSheet = false
                    print("일정 수정 확정")
                }
            )
        }
        .fullScreenCover(item: $selectedVisitPlaceModel) { visitPlaceModel in
            PlaceView(
                setPlaceModel: visitPlaceModel.placeModel,
                setNationalityType: getNationalityType
            )
        }
    }
}

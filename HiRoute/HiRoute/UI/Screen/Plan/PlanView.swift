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
    @Binding private var isShowPlanView : Bool
    init(
        setScheduleModel : ScheduleModel,
        setViewType : PlanViewType,
        setNationalityType : NationalityType,
        setPlanViewVisibiltiy : Binding<Bool>
    ){
        self.getScheduleModel = setScheduleModel
        self.getViewType = setViewType
        self.getNationalityType = setNationalityType
        self._isShowPlanView = setPlanViewVisibiltiy
    }

    
    @State private var memoText : String = "토마토 크림파스타가 맛있다 해서 가볼 예정. 성수역 3번 출구에서 도보 5분 거리. 내부는 조용하고 자리 넓다 함. 주차는 불가하고 애견동반 가능한 매장. 노키즈존이라 안시끄러울듯토마토 크림파스타가 맛있다 해서 가볼 예정. 성수역 3번 출구에서 도보 5분 거리. 내부는 조용하고 자리 넓다 함. 주차는 불가하고 애견동반 가능한 매장. 노키즈존이라 안시끄러울듯토마토 크림파스타가 맛있다 해서 가볼 예정. 성수역 3번 출구에서 도보 5분 거리. 내부는 조용하고 자리 넓다 함. 주차는 불가하고 애견동반 가능한 매장. 노키즈존이라 안시끄러울듯"
    
    @State private var isShowOptionSheet = false
    @State private var isShowPlanDetailView = false
    var body: some View {
        VStack(alignment: HorizontalAlignment.leading){
            PlanToolBar(
                setOnClickBack: {
                    isShowPlanView = false
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
                    isShowPlanDetailView = true
                },
                onClickAnnotation: { selectedVisitPlaceModel in
                    print("클릭된 핀 : \(selectedVisitPlaceModel)")
                }
            )
        }
        .background(Color.getColour(.background_yellow_white))
        .bottomSheet(isOpen: $isShowOptionSheet) {
            <#code#>
        }

    }
}

//
//  ScheduleView.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

struct ScheduleView: View {
    
    private var getScheduleList: [ScheduleModel]
    private var getNationalityType: NationalityType
    
    init(
        setScheduleList: [ScheduleModel],
        setNationalityType: NationalityType
    ) {
        self.getScheduleList = setScheduleList
        self.getNationalityType = setNationalityType
    }
    
    @State private var planViewType: PlanViewType = .read
    @State private var selectedScheduleModel: ScheduleModel?
    
    private func onClickScheduleAdd() {
        planViewType = .add
        selectedScheduleModel = createEmptyScheduleModel()
    }
    
    private func onClickScheduleModel(_ model: ScheduleModel) {
        print("클릭된 셀: \(model.title)")
        planViewType = .read
        selectedScheduleModel = model
    }
    
    private func createEmptyScheduleModel() -> ScheduleModel {
        return ScheduleModel(
            uid: UUID().uuidString,
            index: getScheduleList.count + 1,
            title: "클릭하여 일정 제목을 입력해보세요.",
            memo: "메모",
            editDate: Date(),
            d_day: Date(),
            visitPlaceList: []
        )
    }
    
    var body: some View {
        VStack {
            ScheduleAddButton {
                onClickScheduleAdd()
            }
            
            ScheduleList(
                setList: getScheduleList,
                setNationalityType: getNationalityType,
                setOnClickCell: { model in
                    onClickScheduleModel(model)
                }
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .fullScreenCover(
            item: $selectedScheduleModel,
            onDismiss: {
                selectedScheduleModel = nil
            },
            content: { scheduleModel in
                /*
                 selectedScheduleModel가 unwrapped되어 content 클로저에 scheduleModel로 넘김.
                 */
                PlanView(
                    setScheduleModel: scheduleModel,
                    setViewType: planViewType,
                    setNationalityType: getNationalityType,
                    setPlanViewVisibiltiy: Binding(
                        get: {
                            /*
                             읽기: model이 있으면 true, 없으면 false
                             1. PlanView에서 isShowPlanView를 읽을 때
                             selectedScheduleModel = someModel → true 반환
                             selectedScheduleModel = nil → false 반환
                             */
                            selectedScheduleModel != nil
                        },
                        set: { _ in
                            /*
                             쓰기: 항상 nil로 설정 (화면 닫기)
                             2. PlanView에서 isShowPlanView = false 할 때
                             전달받은 값은 무시하고(_) selectedScheduleModel을 nil로 설정
                             → fullScreenCover가 닫힘
                             */
                            selectedScheduleModel = nil
                        }
                    )
                )
            }
        )
    }
}

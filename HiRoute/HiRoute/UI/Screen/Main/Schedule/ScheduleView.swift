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
        .fullScreenCover(item: $selectedScheduleModel) { scheduleModel in
            PlanView(
                setScheduleModel: scheduleModel,
                setViewType: planViewType,
                setNationalityType: getNationalityType
            )
        }
    }
}

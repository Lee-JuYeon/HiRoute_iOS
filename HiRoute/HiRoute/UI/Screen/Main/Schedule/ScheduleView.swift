//
//  ScheduleView.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

struct ScheduleView: View {
    
    @EnvironmentObject private var scheduleVM: ScheduleViewModel
    @EnvironmentObject private var localVM : LocalVM
    @State private var modeType: ModeType = .READ
   
    private func addSchedule() {
        modeType = .ADD
        let newSchedule = scheduleVM.createEmptySchedule()
        scheduleVM.selectSchedule(newSchedule)
    }
    
    private func onClickScheduleModel(_ model: ScheduleModel) {
        modeType = .READ
        scheduleVM.selectSchedule(model)
    }
    
    private func deleteScheduleModel(_ scheduleUID: String) {
        scheduleVM.deleteSchedule(scheduleUID: scheduleUID)
    }
      
    private func initScheduleData(){
        if scheduleVM.schedules.isEmpty {
            scheduleVM.loadInitialData()
        }
    }
    
    
    @State private var editMode : Bool = false
    @ViewBuilder
    private func filterEditButtons() -> some View{
        HStack(alignment: VerticalAlignment.center, spacing: 0){
            ScheduleListFilterButton { listFilterType in
                scheduleVM.filteredSchedules
            }
            
            Spacer()
            
            ScheduleListEditButton {
                editMode.toggle()
            }
        }
        .padding(16)
    }
    
    var body: some View {
        VStack {
            ScheduleAddButton {
                addSchedule()
            }
            
            filterEditButtons()
            
            ScheduleList(
                setList: scheduleVM.filteredSchedules,
                setNationalityType: localVM.nationality,
                setOnClickCell: { model in
                    onClickScheduleModel(model)
                }
            )
        }
        .onAppear {
            initScheduleData()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .fullScreenCover(item: $scheduleVM.selectedSchedule) { scheduleModel in
            PlanView(
                setModeType: modeType,
                setScheduleModel: scheduleModel
            )
        }
    }
}

//
//  ScheduleView.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

struct ScheduleView: View {
    
    private var getNationalityType: NationalityType
    
    init(
        setNationalityType: NationalityType
    ) {
        self.getNationalityType = setNationalityType
    }
    
    
    @EnvironmentObject var scheduleVM: ScheduleViewModel
    @State private var modeType: ModeType = .READ
   
    private func onClickScheduleAdd() {
        modeType = .ADD
        scheduleVM.selectSchedule(scheduleVM.createEmptySchedule())
    }
    
    private func onClickScheduleModel(_ model: ScheduleModel) {
        modeType = .READ
        scheduleVM.selectSchedule(model)
    }
    
   
    
    var body: some View {
        VStack {
            ScheduleAddButton {
                onClickScheduleAdd()
            }
            
            ScheduleList(
                setList: scheduleVM.filteredSchedules,
                setNationalityType: getNationalityType,
                setOnClickCell: { model in
                    onClickScheduleModel(model)
                }
            )
        }
        .onAppear {
            if scheduleVM.schedules.isEmpty {
                scheduleVM.loadInitialData()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .fullScreenCover(item: $scheduleVM.selectedSchedule) { scheduleModel in
            PlanView(
                setScheduleModel: scheduleModel,
                setModeType: modeType,
                setNationalityType: getNationalityType
            )
        }
    }
}

//
//  ScheduleView.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

struct ScheduleView: View {
    
    @EnvironmentObject private var scheduleVM: ScheduleVM
    @EnvironmentObject private var localVM : LocalVM
    
    @State private var modeType: ModeType = .READ
   
    private var userUID : String = "userUID"
    private func addSchedule() {
        modeType = .CREATE
        scheduleVM.selectedSchedule = ScheduleModel(uid: "schedule_\(userUID)_\(Date())", index: 0, title: "", memo: "", editDate: Date(), d_day: Date(), planList: [])
    }
    
    private func onClickScheduleModel(_ model: ScheduleModel) {
        modeType = .READ
        scheduleVM.selectSchedule(model)
    }
    
    private func deleteScheduleModel(_ scheduleUID: String) {
        scheduleVM.deleteSchedule(scheduleUID: scheduleUID)
    }
    
        
    @ViewBuilder
    private func filterEditButtons() -> some View{
        HStack(alignment: VerticalAlignment.center, spacing: 0){
            ScheduleListFilterButton { listFilterType in
//                switch listFilterType {
//                case .DEFAULT :
//                    scheduleVM.filteredSchedules
//                case .NEWEST :
//                    scheduleVM.filteredSchedules
//                case .OLDEST :
//                    scheduleVM.filteredSchedules
//                }
            }
            
            Spacer()
                       
            TextButton(
                text: "편집",
                textSize: 16,
                textColour: Color.getColour(.label_strong),
                callBackClick: {
                    modeType = ModeType.UPDATE
                }
            )
        }
        .padding(16)
    }
    
    @ViewBuilder
    private func scheduleListView() -> some View {
        if scheduleVM.isLoading {
            ProgressView("일정 로딩 중...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage = scheduleVM.errorMessage {
            VStack {
                Text("오류가 발생했습니다")
                    .font(.headline)
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.gray)
                Button("다시 시도") {
                    // 데이터 새로고침
                    scheduleVM.refreshScheduleList()
                }
                .padding()
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .center
            )
        } else {
            if scheduleVM.schedules.isEmpty {
                Text("작성된 일정이 없네요, 일정을 추가해볼까요?")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .center
                    )
            }else{
                ScheduleList(
                    setList: scheduleVM.schedules,
                    setNationalityType: localVM.nationality,
                    setOnClickCell: { model in
                        onClickScheduleModel(model)
                    }
                )
            }
        }
    }
    
    var body: some View {
        VStack {
            ScheduleAddButton {
                addSchedule()
            }
            
            filterEditButtons()
            
            scheduleListView()
        }
        .onAppear {
            scheduleVM.initData()
            scheduleVM.printAllCoreData()
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

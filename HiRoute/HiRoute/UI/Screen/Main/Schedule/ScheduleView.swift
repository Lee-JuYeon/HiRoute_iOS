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
    @State private var editMode: Bool = false
    @State private var isOfflineMode: Bool = false
   
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
        // ✅ 수정: 오프라인 대응 삭제
        if isOfflineMode {
            scheduleVM.markForDeletion(scheduleUID)
        } else {
            scheduleVM.delete(scheduleUID: scheduleUID)
        }
    }
      
    private func initScheduleData(){
        // 로컬 데이터 먼저 로드
        if scheduleVM.schedules.isEmpty {
            scheduleVM.loadFromCache()
        }
        // 백그라운드에서 서버 동기화
        if !isOfflineMode {
            scheduleVM.syncWithServer()
        }
    }
    
    
    @State private var editMode : Bool = false
    @ViewBuilder
    private func filterEditButtons() -> some View{
        HStack(alignment: VerticalAlignment.center, spacing: 0){
            ScheduleListFilterButton { listFilterType in
                scheduleVM.applyFilter(listFilterType)
                return scheduleVM.filteredSchedules
            }
            
            Spacer()
            
            // ✅ 추가: 오프라인 인디케이터
            if isOfflineMode {
                Image(systemName: "wifi.slash")
                    .foregroundColor(.orange)
                    .padding(.trailing, 8)
            }
                       
            ScheduleListEditButton {
                editMode.toggle()
            }
        }
        .padding(16)
    }
    
    @ViewBuilder
    private func scheduleListView() -> some View {
        if scheduleVM.isLoading {
            ProgressView("스케줄 로딩 중...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage = scheduleVM.errorMessage {
            VStack {
                Text("오류가 발생했습니다")
                    .font(.headline)
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.gray)
                Button("다시 시도") {
                    initScheduleData()
                }
                .padding()
            }
        } else {
            ScheduleList(
                setList: scheduleVM.filteredSchedules,
                setNationalityType: localVM.nationality,
                setOnClickCell: { model in
                    onClickScheduleModel(model)
                }
            )
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
            checkNetworkStatus()
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
    
    private func checkNetworkStatus() {
        isOfflineMode = !NetworkMonitor.shared.isConnected
    }
}

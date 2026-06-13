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
    
    private var userUid : String = "userUid"
    @EnvironmentObject private var navigationVM : NavigationVM

    @State private var isEditMode: Bool = false
    @State private var showDeleteConfirm: Bool = false
    @State private var deleteTargetUID: String? = nil

    private func addSchedule() {
        navigationVM.currentModeType = .CREATE
        let newSchedule = ScheduleModel(
            uid: "schedule_\(userUid)_\(Date())",
            index: 0,
            title: "",
            memo: "",
            editDate: Date(),
            d_day: Date(),
            planList: []
        )
        scheduleVM.selectedSchedule = newSchedule
        scheduleVM.startEditing(newSchedule)
        navigationVM.navigateTo(setDestination: .plan)
    }

    private func onClickScheduleModel(_ model: ScheduleModel) {
        navigationVM.currentModeType = .READ
        scheduleVM.selectSchedule(model)
        navigationVM.navigateTo(setDestination: .plan)
    }
    
    private func deleteScheduleModel(_ scheduleUID: String) {
        scheduleVM.deleteSchedule(scheduleUID: scheduleUID)
    }
    
        
    @ViewBuilder
    private func filterEditButtons() -> some View{
        HStack(alignment: VerticalAlignment.center, spacing: 0){
            ScheduleListFilterButton { listFilterType in
                scheduleVM.currentFilter = listFilterType
            }

            Spacer()

            TextButton(
                text: isEditMode ? "완료" : "편집",
                textSize: 16,
                textColour: Color.getColour(.label_strong),
                callBackClick: {
                    isEditMode.toggle()
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
                    setList: scheduleVM.sortedSchedules,
                    setNationalityType: localVM.nationality,
                    setIsEditMode: isEditMode,
                    setOnClickCell: { model in
                        onClickScheduleModel(model)
                    },
                    setOnClickDelete: { scheduleUID in
                        deleteTargetUID = scheduleUID
                        showDeleteConfirm = true
                    },
                    setOnMove: { from, to in
                        scheduleVM.updateScheduleIndex(from: from, to: to)
                    },
                    setOnLongPress: {
                        isEditMode = true
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
        .bottomSheet(isOpen: $showDeleteConfirm) {
            VStack(alignment: .center, spacing: 16) {
                Text("이 일정을 삭제할까요?")
                    .font(.system(size: 16))
                    .foregroundColor(Color.getColour(.label_strong))
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)

                HStack(spacing: 12) {
                    StrokeTextButton(text: "취소") {
                        showDeleteConfirm = false
                        deleteTargetUID = nil
                    }
                    .frame(maxWidth: .infinity)
                    
                    FillTextButton(text: "삭제") {
                        if let uid = deleteTargetUID {
                            scheduleVM.deleteSchedule(scheduleUID: uid)
                        }
                        showDeleteConfirm = false
                        deleteTargetUID = nil
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
        }

    }
 
}

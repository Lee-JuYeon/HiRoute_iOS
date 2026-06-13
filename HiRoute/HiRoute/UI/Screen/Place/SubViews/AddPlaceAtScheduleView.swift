//
//  AddPlaceAtScheduleView.swift
//  HiRoute
//
//  Created by Jupond on 3/13/26.
//
import SwiftUI

struct AddPlaceAtScheduleView: View {

    @EnvironmentObject private var placeVM: PlaceVM
    @EnvironmentObject private var localVM: LocalVM
    @EnvironmentObject private var scheduleVM: ScheduleVM

    let placeToAdd: PlaceModel
    let onComplete: () -> Void

    @State private var selectedScheduleUID: String? = nil
    @State private var isDuplicateWarning: Bool = false
    @State private var duplicatePlaceName: String = ""

    init(placeToAdd: PlaceModel, onComplete: @escaping () -> Void) {
        self.placeToAdd = placeToAdd
        self.onComplete = onComplete
    }

    @ViewBuilder
    private func savedScheduleListCell(_ savedScheduleModel: ScheduleModel) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                CheckBox(
                    isChecked: .constant(selectedScheduleUID == savedScheduleModel.uid)
                ) {
                    selectedScheduleUID = savedScheduleModel.uid
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(savedScheduleModel.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.getColour(.label_strong))
                        .lineLimit(1)

                    if !savedScheduleModel.memo.isEmpty {
                        Text(savedScheduleModel.memo)
                            .font(.system(size: 14))
                            .foregroundColor(Color.getColour(.label_normal))
                            .lineLimit(2)
                    }

                    Text(formatDate(savedScheduleModel.d_day))
                        .font(.system(size: 12))
                        .foregroundColor(Color.getColour(.label_alternative))
                }

                Spacer()
            }

            // hierarchy: 기존 planList 장소 제목 축약 표시
            if !savedScheduleModel.planList.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(savedScheduleModel.planList.prefix(3), id: \.uid) { plan in
                        Text("· \(plan.placeModel.title)")
                            .font(.system(size: 12))
                            .foregroundColor(Color.getColour(.label_alternative))
                            .lineLimit(1)
                    }
                    if savedScheduleModel.planList.count > 3 {
                        Text("외 \(savedScheduleModel.planList.count - 3)곳")
                            .font(.system(size: 11))
                            .foregroundColor(Color.getColour(.label_disable))
                    }
                }
                .padding(.leading, 44)
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedScheduleUID = savedScheduleModel.uid
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func addPlaceToSchedule() {
        guard let targetUID = selectedScheduleUID,
              let targetSchedule = scheduleVM.schedules.first(where: { $0.uid == targetUID }) else { return }

        // 중복 확인 → 인라인 경고 표시
        let isDuplicate = targetSchedule.planList.contains { $0.placeModel.uid == placeToAdd.uid }
        if isDuplicate {
            duplicatePlaceName = placeToAdd.title
            isDuplicateWarning = true
            return
        }

        performAddPlace(to: targetSchedule)
    }

    private func performAddPlace(to targetSchedule: ScheduleModel) {
        let newPlan = PlanModel(
            uid: UUID().uuidString,
            index: targetSchedule.planList.count,
            memo: "",
            placeModel: placeToAdd,
            files: []
        )

        var updatedPlanList = targetSchedule.planList
        updatedPlanList.append(newPlan)

        let updatedSchedule = ScheduleModel(
            uid: targetSchedule.uid,
            index: targetSchedule.index,
            title: targetSchedule.title,
            memo: targetSchedule.memo,
            editDate: targetSchedule.editDate,
            d_day: targetSchedule.d_day,
            planList: updatedPlanList
        )

        scheduleVM.updateSchedule(schedule: updatedSchedule)
        placeVM.showSnackBarAddPlace = true
        onComplete()
    }

    var body: some View {
        LazyVStack(spacing: 20) {

            VStack(spacing: 8) {
                Text("방문할 장소 추가")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color.getColour(.label_strong))

                Text("해당 장소를 추가할 일정을 선택해주세요")
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_alternative))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)

            if scheduleVM.schedules.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 48))
                        .foregroundColor(Color.getColour(.label_alternative))

                    Text("저장된 일정이 없습니다")
                        .font(.system(size: 16))
                        .foregroundColor(Color.getColour(.label_alternative))
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 8) {
                        ForEach(scheduleVM.schedules, id: \.uid) { savedScheduleModel in
                            savedScheduleListCell(savedScheduleModel)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }

            if isDuplicateWarning {
                Text("이미 \(duplicatePlaceName)이 있네요! 계속 추가할까요?")
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_alternative))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }

            HStack(spacing: 12) {
                FillTextButton(text: isDuplicateWarning ? "취소" : "닫기") {
                    if isDuplicateWarning {
                        isDuplicateWarning = false
                    } else {
                        placeVM.showAddScheduleView = false
                    }
                }
                .frame(maxWidth: .infinity)

                StrokeTextButton(text: isDuplicateWarning ? "추가" : "선택하기") {
                    if isDuplicateWarning {
                        isDuplicateWarning = false
                        if let targetUID = selectedScheduleUID,
                           let targetSchedule = scheduleVM.schedules.first(where: { $0.uid == targetUID }) {
                            performAddPlace(to: targetSchedule)
                        }
                    } else {
                        addPlaceToSchedule()
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .background(Color.getColour(.background_yellow_white))
        .onAppear {
            scheduleVM.initData()
        }
    }
}




//
//  ScheduleDDayEditSheet.swift
//  HiRoute
//
//  Created by Jupond on 5/24/26.
//

import SwiftUI

/// 일정 d_day 설정 — TopSheet 컨텐츠로 사용.
/// 저장 시 ScheduleModel.d_day 업데이트.
/// 부모는 .topSheet(isOpen:) { 이 뷰 } 로 호출, onSave/onCancel 에서 isOpen=false 처리.
struct ScheduleDDayEditSheet: View {
    @Environment(\.presentationMode) private var presentationMode

    let initialDate: Date
    let onSave: (Date) -> Void
    let onCancel: () -> Void

    @State private var date: Date = Date()

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            DatePicker(
                "여행 날짜",
                selection: $date,
                displayedComponents: .date
            )
            .datePickerStyle(GraphicalDatePickerStyle())
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .onAppear { date = initialDate }
    }

    private var toolbar: some View {
        HStack {
            Button(action: {
                onCancel()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("취소")
                    .foregroundColor(Color.getColour(.label_neutral))
            }
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))

            Spacer()

            Text("여행 날짜 설정")
                .font(.headline)
                .foregroundColor(Color.getColour(.label_strong))
                .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))

            Spacer()

            Button(action: {
                onSave(date)
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("저장")
                    .foregroundColor(Color.getColour(.label_strong))
                    .fontWeight(.semibold)
            }
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
        }
        .padding(.horizontal, 8)
    }
}

//
//  ScheduleTitleEditSheet.swift
//  HiRoute
//
//  Created by Jupond on 5/24/26.
//

import SwiftUI

/// 일정 제목 수정 — TopSheet 컨텐츠로 사용.
/// 저장 시 ScheduleModel.title + 링크된 ChatConversation.title 동시 업데이트.
/// 부모는 .topSheet(isOpen:) { 이 뷰 } 로 호출, onSave/onCancel 에서 isOpen=false 처리.
struct ScheduleTitleEditSheet: View {
    @Environment(\.presentationMode) private var presentationMode

    let initialTitle: String
    let onSave: (String) -> Void
    let onCancel: () -> Void

    @State private var text: String = ""

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            TextField("일정 제목을 입력하세요", text: $text)
                .font(.system(size: 16))
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.getColour(.fill_alternative))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 12)
        }
        .onAppear { text = initialTitle }
    }

    private var toolbar: some View {
        HStack {
            Button(action: {
                hideKeyboard()
                onCancel()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("취소")
                    .foregroundColor(Color.getColour(.label_neutral))
            }
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))

            Spacer()

            Text("일정 제목 수정")
                .font(.headline)
                .foregroundColor(Color.getColour(.label_strong))
                .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))

            Spacer()

            Button(action: {
                guard canSave else { return }
                hideKeyboard()
                onSave(text)
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("저장")
                    .foregroundColor(canSave ? Color.getColour(.label_strong) : Color.getColour(.label_assistive))
                    .fontWeight(.semibold)
            }
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            .disabled(!canSave)
        }
        .padding(.horizontal, 8)
    }

    private var canSave: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}

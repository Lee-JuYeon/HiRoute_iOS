//
//  RootDetailScheduleView.swift
//  HiRoute
//
//  Created by Jupond on 7/23/25.
//

import SwiftUI
struct SheetPlanOptionView: View {
    
    private let onDelete: () -> Void
    private let onEdit: () -> Void
    
    init(
        setOnClickDeleteOption: @escaping () -> Void,
        setOnClickEditOption: @escaping () -> Void
    ) {
        self.onDelete = setOnClickDeleteOption
        self.onEdit = setOnClickEditOption
    }
    
    @State private var isExpandSureDeleteView = false
    
    @ViewBuilder
    private func deleteButton() -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                isExpandSureDeleteView = true
            }
        } label: {
            if isExpandSureDeleteView {
                VStack(spacing: 16) {
                    Text("정말로 삭제할까요? 데이터는 복구되지 않습니다")
                        .font(.system(size: 16))
                        .foregroundColor(Color.getColour(.label_strong))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .transition(.opacity.combined(with: .scale)) // ✅ 텍스트 애니메이션
                    
                    HStack(spacing: 12) {
                        // ✅ 삭제합니다 버튼 (왼쪽)
                        Button {
                            isExpandSureDeleteView = false
                            onDelete()
                        } label: {
                            Text("삭제합니다")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.getColour(.label_strong)) // 텍스트 검은색
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(Color.getColour(.background_white)) // 바탕 하얀색
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.getColour(.label_strong), lineWidth: 1) // 테두리 검은색 1dp
                                )
                                .cornerRadius(12)
                                .customElevation(.normal)

                        }
                        
                        // ✅ 취소합니다 버튼 (오른쪽)
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isExpandSureDeleteView = false
                            }
                        } label: {
                            Text("취소합니다")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.getColour(.label_assistive)) // 텍스트 하얀색
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(Color.getColour(.label_strong)) // 바탕 검은색
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.getColour(.label_assistive), lineWidth: 1) // 테두리 하얀색 1dp
                                )
                                .cornerRadius(12)
                                .customElevation(.normal)

                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 20)
                .background(Color.getColour(.background_white))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.getColour(.line_alternative), lineWidth: 1)
                )
                .cornerRadius(12)
                
            } else {
                Text("일정 삭제")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(Color.getColour(.background_white))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.getColour(.line_alternative), lineWidth: 1)
                    )
                    .cornerRadius(12)
                    .customElevation(.normal)
                    .transition(.opacity.combined(with: .scale)) // ✅ 기본 텍스트 애니메이션

            }
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private func editButton() -> some View {
        Button {
            onEdit()
        } label: {
            Text("일정 수정")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.getColour(.label_strong))
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(Color.getColour(.background_white))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.getColour(.line_alternative), lineWidth: 1)
                )
                .cornerRadius(12)
        }
        .customElevation(.normal)
        .padding(.horizontal, 16)
    }
    
    var body: some View {
        VStack(
            alignment: .center,
            spacing: 12
        ) {
            deleteButton()
            
            editButton()
        }
        .background(Color.getColour(.background_white))
        .padding(.vertical, 16)
    }
}

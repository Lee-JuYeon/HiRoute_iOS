//
//  RootDetailScheduleView.swift
//  HiRoute
//
//  Created by Jupond on 7/23/25.
//

import SwiftUI

struct SheetPlanOptionView : View {
    
    private let onDelete : () -> Void
    private let onEdit : () -> Void
    init(
        setOnClickDeleteOption : @escaping () -> Void,
        setOnClickEditOption : @escaping () -> Void
    ){
        self.onDelete = setOnClickDeleteOption
        self.onEdit = setOnClickEditOption
    }
    
    @State private var isExpandSureDeleteView = false
    @ViewBuilder
    private func deleteButton() -> some View {
        return Button {
            isExpandSureDeleteView = true
        } label: {
            if isExpandSureDeleteView {
                VStack(){
                    Text("정말 일정을 삭제할까요?")
                    HStack(){
                        Button {
                            onDelete()
                        } label: {
                            Text("삭제")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.getColour(.line_alternative), lineWidth: 1)
                                )
                                .customElevation(Elevation.normal)
                                .cornerRadius(12)
                                .padding(
                                    EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
                                )
                        }
                        
                        Button {
                            isExpandSureDeleteView = false
                        } label: {
                            Text("취소")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.getColour(.line_alternative), lineWidth: 1)
                                )
                                .customElevation(Elevation.normal)
                                .cornerRadius(12)
                                .padding(
                                    EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
                                )
                        }

                    }
                }
            }else {
                Text("일정 삭제")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.getColour(.line_alternative), lineWidth: 1)
                    )
                    .customElevation(Elevation.normal)
                    .cornerRadius(12)
                    .padding(
                        EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
                    )
            }
        }

    }
    
    @ViewBuilder
    private func editButton() -> some View {
        return Button {
            onEdit()
        } label: {
            Text("수정")
        }

    }
    
    var body: some View {
        VStack(
            alignment : HorizontalAlignment.center,
            spacing: 10
        ){
            deleteButton()
            editButton()
        }
    }
}

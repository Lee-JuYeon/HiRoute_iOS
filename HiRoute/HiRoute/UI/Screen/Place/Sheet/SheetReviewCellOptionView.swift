//
//  SheetReviewCellOptionView.swift
//  HiRoute
//
//  Created by Jupond on 11/22/25.
//
import SwiftUI

struct SheetReviewCellOptionView : View {
    
    private var reviewModel : ReviewModel
    private let callBackReport: (ReviewModel, String) -> Void
    
    init(
        setReviewModel : ReviewModel,
        onCallBackReport: @escaping (ReviewModel, String) -> Void
    ) {
        self.reviewModel = setReviewModel
        self.callBackReport = onCallBackReport
    }
    
    @State private var selectedReportType: ReportType? = nil
    @ViewBuilder
    private func toggleButton(for reportType: ReportType) -> some View {
        let isSelected = selectedReportType == reportType
        
        Button {
            selectedReportType = isSelected ? nil : reportType
        } label: {
            Circle()
                .fill(isSelected ? Color.getColour(.label_strong) : Color.getColour(.background_white))
                .frame(width: 20, height: 20)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.clear : Color.getColour(.label_alternative), lineWidth: 1)
                )
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(isSelected ? Color.getColour(.background_white) : Color.getColour(.label_alternative))
                )
        }
    }
    
    @ViewBuilder
    private func reportOptionsList() -> some View {
        LazyVStack(spacing: 12) {
            ForEach(ReportType.allCases, id: \.self) { reportType in
                HStack(spacing: 12) {
                    toggleButton(for: reportType)
                    
                    Text(reportType.displayText)
                        .font(.system(size: 14))
                        .foregroundColor(Color.getColour(.label_strong))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .onTapGesture {
                    let isSelected = selectedReportType == reportType
                    selectedReportType = isSelected ? nil : reportType
                }
            }
        }
    }
    
    @State private var isExpandReportView = false
    @ViewBuilder
    private func reportButton() -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                isExpandReportView.toggle()
            }
        } label: {
            if isExpandReportView {
                VStack(spacing: 16) {
                    Text("신고 사유를 선택해주세요")
                        .font(.system(size: 16))
                        .foregroundColor(Color.getColour(.label_strong))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .transition(.opacity.combined(with: .scale))
                    
                    // 신고 옵션 리스트
                    reportOptionsList()
                    
                    HStack(spacing: 12) {
                        // 신고하기 버튼 (왼쪽)
                        Button {
                            if let selectedType = selectedReportType {
                                isExpandReportView = false
                                callBackReport(reviewModel, selectedType.displayText)
                            }
                        } label: {
                            Text("신고하기")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(selectedReportType != nil ? Color.getColour(.background_white) : Color.getColour(.label_alternative))
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(selectedReportType != nil ? Color.getColour(.label_strong) : Color.getColour(.label_disable))
                                .cornerRadius(12)
                                .customElevation(.normal)
                        }
                        .disabled(selectedReportType == nil)
                        
                        // 취소 버튼 (오른쪽)
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isExpandReportView = false
                                selectedReportType = nil
                            }
                        } label: {
                            Text("취소")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.getColour(.label_strong))
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(Color.getColour(.background_white))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.getColour(.label_strong), lineWidth: 1)
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
                Text("리뷰 신고")
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
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .padding(.horizontal, 16)
    }
    
    var body: some View {
        VStack(
            alignment: .center,
            spacing: 12
        ) {
            reportButton()
        }
        .background(Color.getColour(.background_white))
        .padding(.vertical, 16)
    }
}

//
//  SheetReviewDetailView.swift
//  HiRoute
//
//  Created by Jupond on 3/4/26.
//

import SwiftUI

/// 리뷰 셀 탭 → 디테일 바텀시트.
/// 리뷰 텍스트 전체(lineLimit 없음) + 이미지 가로 스크롤 + 도움돼요 + 신고.
struct SheetReviewDetailView: View {

    private let model: ReviewModel
    private let nationalityType: NationalityType

    @EnvironmentObject private var placeVM: PlaceVM

    init(
        setModel: ReviewModel,
        setNationalityType: NationalityType
    ) {
        self.model = setModel
        self.nationalityType = setNationalityType
    }

    // MARK: - State

    @State private var selectedImageModel: ReviewModel? = nil
    @State private var isExpandReportView: Bool = false
    @State private var selectedReportType: ReportType? = nil

    // MARK: - Header

    @ViewBuilder
    private func headerSection() -> some View {
        HStack(alignment: .center, spacing: 0) {
            Text("\(model.userName)")
                .font(.system(size: 14))
                .foregroundColor(Color.getColour(.label_strong))
                .fontWeight(.bold)
                .lineLimit(1)

            Text("\((model.visitDateAsDate ?? Date()).toLocalizedDateString(region: nationalityType)) 방문")
                .font(.system(size: 12))
                .foregroundColor(Color.getColour(.label_neutral))
                .fontWeight(.light)
                .lineLimit(1)
                .padding(.leading, 20)

            if model.rating > 0 {
                HStack(alignment: .center, spacing: 2) {
                    Image("icon_star_fill")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 12, height: 12)
                        .foregroundColor(Color.getColour(.label_strong))

                    Text("\(model.rating)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.getColour(.label_strong))
                }
                .padding(.leading, 8)
            }

            Spacer()

            Text("신고")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color.getColour(.label_alternative))
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpandReportView.toggle()
                    }
                }
        }
    }

    // MARK: - Review Text

    @ViewBuilder
    private func reviewTextSection() -> some View {
        Text(model.reviewText ?? "")
            .font(.system(size: 14))
            .foregroundColor(Color.getColour(.label_normal))
            .fontWeight(.light)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Images

    @ViewBuilder
    private func imageSection() -> some View {
        if !model.images.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(model.images, id: \.id) { imageModel in
                        ServerImageView(setImageURL: imageModel.imageUrl)
                            .frame(width: 160, height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .clipped()
                            .aiWatermark(isAiGenerated: imageModel.isAiGenerated, size: .normal)
                            .onTapGesture {
                                selectedImageModel = model
                            }
                    }
                }
            }
        }
    }

    // MARK: - Useful

    @ViewBuilder
    private func usefulSection() -> some View {
        HStack(alignment: .center, spacing: 2) {
            Text("도움 돼요")
                .font(.system(size: 12))
                .foregroundColor(Color.getColour(.label_strong))
                .fontWeight(.light)
                .lineLimit(1)

            Image((model.usefulList ?? []).contains(where: { usefulModel in
                usefulModel.userUid == (UserDefaults.standard.string(forKey: "currentUserUID") ?? "")
            }) ? "icon_like_on" : "icon_like_off")
                .renderingMode(.template)
                .resizable()
                .foregroundColor(Color.getColour(.label_strong))
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)

            Text("\(model.usefulCount)")
                .font(.system(size: 12))
                .foregroundColor(Color.getColour(.label_strong))
                .fontWeight(.light)
                .lineLimit(1)
        }
    }

    // MARK: - Report (인라인 확장)

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
    private func reportSection() -> some View {
        if isExpandReportView {
            VStack(spacing: 16) {
                Text("신고 사유를 선택해주세요")
                    .font(.system(size: 16))
                    .foregroundColor(Color.getColour(.label_strong))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

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

                HStack(spacing: 12) {
                    Button {
                        if let selectedType = selectedReportType {
                            placeVM.events.reportReview(
                                reviewUid: model.reviewUid,
                                reportType: selectedType.displayText
                            )
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isExpandReportView = false
                                selectedReportType = nil
                            }
                        }
                    } label: {
                        Text("신고하기")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(selectedReportType != nil ? Color.getColour(.background_white) : Color.getColour(.label_alternative))
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(selectedReportType != nil ? Color.getColour(.label_strong) : Color.getColour(.label_disable))
                            .cornerRadius(12)
                    }
                    .disabled(selectedReportType == nil)

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
            .padding(.horizontal, 16)
            .transition(.opacity.combined(with: .scale))
        }
    }

    // MARK: - Body

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 12) {
                headerSection()
                imageSection()
                reviewTextSection()
                usefulSection()
                reportSection()
            }
            .padding(16)
        }
        .background(Color.getColour(.background_white))
        .fullScreenCover(item: $selectedImageModel) { reviewModel in
            FullSizeImageListView(setImageList: reviewModel.images)
        }
    }
}

//
//  ReviewWriteView.swift
//  HiRoute
//
//  Created by Jupond on 3/4/26.
//
import SwiftUI

struct ReviewWriteView: View {

    @EnvironmentObject private var navigationVM: NavigationVM
    @EnvironmentObject private var placeVM: PlaceVM
    @EnvironmentObject private var scheduleVM: ScheduleVM
    @EnvironmentObject private var userVM: UserVM

    @State private var reviewText: String = ""
    @State private var reviewImages: [FileModel] = []
    @State private var selectedRating: Int = 0
    @State private var visitDate: Date = Date()
    @State private var showImagePicker: Bool = false
    @State private var showDatePicker: Bool = false
    @State private var fullScreenImageIndex: Int? = nil

    // MARK: - Submit

    private func submitReview() {
        guard !reviewText.isEmpty, selectedRating > 0,
              let placeUid = scheduleVM.currentPlanModel?.placeModel.uid else { return }

        let formatter = ISO8601DateFormatter()
        let reviewModel = ReviewModel(
            reviewUid: UUID().uuidString,
            userUid: userVM.currentUserUID,
            userName: userVM.currentUser?.name ?? "",
            visitDate: formatter.string(from: visitDate),
            rating: selectedRating
        )

        placeVM.createReview(placeUid: placeUid, reviewModel: reviewModel)
        placeVM.ratePlace(placeUid: placeUid, rating: selectedRating)
        navigationVM.navigateTo(setDestination: .place)
    }

    // MARK: - Image Handling

    private func handlePickedImages(_ images: [(UIImage, Bool)]) {
        for (image, isAI) in images {
            guard let data = image.jpegData(compressionQuality: 0.8) else { continue }
            let fileName = "\(UUID().uuidString).jpg"
            let fileModel = FileModel.forUpload(
                data: data,
                fileName: fileName,
                fileType: "jpg",
                isAiGenerated: isAI
            )
            reviewImages.append(fileModel)
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func toolbarSection() -> some View {
        HStack(alignment: .center, spacing: 0) {
            TextButton(
                text: "취소",
                textSize: 16,
                textColour: Color.getColour(.label_alternative)
            ) {
                navigationVM.navigateTo(setDestination: .place)
            }

            Spacer()

            Text("리뷰 작성")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.getColour(.label_strong))

            Spacer()

            TextButton(
                text: "보내기",
                textSize: 16,
                textColour: (reviewText.isEmpty || selectedRating == 0)
                    ? Color.getColour(.label_alternative)
                    : Color.getColour(.label_strong)
            ) {
                submitReview()
            }
        }
        .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
    }

    @ViewBuilder
    private func ratingSection() -> some View {
        HStack(alignment: .center, spacing: 10) {
            Image("icon_star_fill")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
                .foregroundColor(Color.getColour(.label_strong))

            Text("별점")
                .font(.system(size: 14))
                .foregroundColor(Color.getColour(.label_normal))

            Spacer()

            StarRatingInputView(rating: $selectedRating)
        }
    }

    @ViewBuilder
    private func textInputSection() -> some View {
        ZStack(alignment: .topLeading) {
            if reviewText.isEmpty {
                Text("해당 장소는 어떠셨나요?")
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_alternative))
                    .padding(EdgeInsets(top: 12, leading: 4, bottom: 0, trailing: 4))
            }
            TextEditor(text: $reviewText)
                .font(.system(size: 14))
                .foregroundColor(Color.getColour(.label_strong))
                .frame(minHeight: 120)
                .background(Color.getColour(.background_yellow_white))
        }
    }

    @ViewBuilder
    private func visitDateSection() -> some View {
        HStack(alignment: .center, spacing: 10) {
            Image("icon_calendar")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
                .foregroundColor(Color.getColour(.label_strong))

            Text("방문날짜")
                .font(.system(size: 14))
                .foregroundColor(Color.getColour(.label_normal))

            Spacer()

            Text(visitDate.toLocalizedDateString(region: .KOREA))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.getColour(.label_strong))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            showDatePicker.toggle()
        }
        .bottomSheet(isOpen: $showDatePicker) {
            VStack(alignment: .center, spacing: 12) {
                Text("방문 날짜")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.getColour(.label_strong))

                DatePicker(
                    "",
                    selection: $visitDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .accentColor(Color.getColour(.label_strong))
            }
            .padding(.horizontal, 16)
        }
    }

    @ViewBuilder
    private func imageSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                // "+" 이미지 추가 버튼
                Button(action: { showImagePicker = true }) {
                    VStack {
                        Image(systemName: "plus")
                            .font(.system(size: 20))
                            .foregroundColor(Color.getColour(.label_alternative))
                    }
                    .frame(width: 64, height: 64)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.getColour(.label_alternative), lineWidth: 1)
                    )
                }
                .padding(.top, 8)

                // 이미지 썸네일 리스트
                if !reviewImages.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(reviewImages.enumerated()), id: \.element.id) { index, fileModel in
                                imageThumbnail(fileModel: fileModel, index: index)
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func imageThumbnail(fileModel: FileModel, index: Int) -> some View {
        VStack(spacing: 0) {
            ZStack {
                if let data = fileModel.data, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            fullScreenImageIndex = index
                        }
                }

                // 삭제 버튼 (우상단)
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color.getColour(.background_white))
                            .frame(width: 20, height: 20)
                            .background(Circle().fill(Color.getColour(.label_strong)))
                            .onTapGesture {
                                reviewImages.remove(at: index)
                            }
                    }
                    Spacer()
                }

                // AI 뱃지 (우하단) — AIWatermarkModifier 적용
                Color.clear
                    .aiWatermark(isAiGenerated: fileModel.isAiGenerated, size: .thumbnail)
            }
            .frame(width: 72, height: 72)
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            toolbarSection()

            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 16) {
                    textInputSection()
                    imageSection()
                    visitDateSection()
                    ratingSection()
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color.getColour(.background_yellow_white))
        .fullScreenCover(isPresented: $showImagePicker) {
            PhotoGridPickerView { images in
                handlePickedImages(images)
            }
        }
        .fullScreenCover(isPresented: Binding(
            get: { fullScreenImageIndex != nil },
            set: { if !$0 { fullScreenImageIndex = nil } }
        )) {
            if let idx = fullScreenImageIndex, idx < reviewImages.count,
               let data = reviewImages[idx].data {
                FullSizeImageView(
                    onClose: { fullScreenImageIndex = nil },
                    trailing: { AIToggleCapsule(isAiGenerated: $reviewImages[idx].isAiGenerated) }
                ) {
                    ImageViewer(
                        data: data,
                        scale: .constant(1.0),
                        offset: .constant(.zero)
                    )
                }
            }
        }
    }
}

//
//  FullSizeImageListView.swift
//  HiRoute
//
//  Created by Jupond on 11/23/25.
//

import SwiftUI

struct FullSizeImageListView : View {

    private let imageList: [ImageModel]?
    private let useNavigation: Bool
    @EnvironmentObject private var placeVM: PlaceVM
    @EnvironmentObject private var navigationVM: NavigationVM
    @Environment(\.presentationMode) var presentationMode
    @State private var currentIndex = 0

    /// fullScreenCover용 — 파라미터로 이미지 전달
    init(setImageList: [ImageModel]) {
        self.imageList = setImageList
        self.useNavigation = false
    }

    /// 네비게이션용 — PlaceVM.currentPlaceImages 사용
    init() {
        self.imageList = nil
        self.useNavigation = true
    }

    private var images: [ImageModel] {
        imageList ?? placeVM.fullScreenImages
    }

    var body: some View {
        FullSizeImageView(onClose: {
            if useNavigation {
                navigationVM.goBack()
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }) {
            TabView(selection: $currentIndex) {
                ForEach(Array(images.enumerated()), id: \.element.id) { index, imageModel in
                    ServerImageView(setImageURL: imageModel.imageUrl)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .aiWatermark(isAiGenerated: imageModel.isAiGenerated, size: .normal)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
        }
    }
}


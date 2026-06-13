//
//  MyUsefulsView.swift
//  HiRoute
//
//  Created by Jupond on 3/6/26.
//

import SwiftUI

/// 내가 도움돼요 누른 리뷰 리스트
struct MyUsefulsView: View {

    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var navigationVM: NavigationVM
    @EnvironmentObject private var placeVM: PlaceVM
    @EnvironmentObject private var localVM: LocalVM

    private func dismissView() {
        presentationMode.wrappedValue.dismiss()
        navigationVM.navigateTo(setDestination: .main)
    }

    var body: some View {
        VStack(spacing: 0) {
            // 상단바
            HStack {
                ImageButton(
                    imageUrl: "icon_back",
                    imageSize: 30
                ) {
                    dismissView()
                }
                Spacer()
                Text("도움돼요 누른 리뷰")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.getColour(.label_strong))
                Spacer()
                Color.clear.frame(width: 30, height: 30)
            }
            .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))

            if placeVM.myUsefulReviews.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "hand.thumbsup.circle")
                        .font(.system(size: 48))
                        .foregroundColor(Color.getColour(.label_alternative))
                    Text("도움돼요를 누른 리뷰가 없습니다")
                        .font(.system(size: 16))
                        .foregroundColor(Color.getColour(.label_alternative))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(.vertical) {
                    LazyVStack(spacing: 0) {
                        ForEach(placeVM.myUsefulReviews, id: \.reviewUid) { reviewModel in
                            ReviewCell(
                                setModel: reviewModel,
                                setNationalityType: localVM.nationality,
                                onCallBackOption: { _ in },
                                onCallBackUseful: { _ in }
                            )
                        }
                    }
                }
            }
        }
        .background(Color.getColour(.background_yellow_white))
        .onAppear {
            placeVM.loadMyUsefulReviews()
        }
    }
}

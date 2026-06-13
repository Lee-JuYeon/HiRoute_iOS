//
//  MyBookmarksView.swift
//  HiRoute
//
//  Created by Jupond on 3/6/26.
//

import SwiftUI

/// 내가 북마크한 장소 리스트
struct MyBookmarksView: View {

    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var navigationVM: NavigationVM
    @EnvironmentObject private var placeVM: PlaceVM

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
                Text("내가 북마크한 곳")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.getColour(.label_strong))
                Spacer()
                Color.clear.frame(width: 30, height: 30)
            }
            .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))

            if placeVM.myBookmarkedPlaces.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "bookmark.slash")
                        .font(.system(size: 48))
                        .foregroundColor(Color.getColour(.label_alternative))
                    Text("북마크한 장소가 없습니다")
                        .font(.system(size: 16))
                        .foregroundColor(Color.getColour(.label_alternative))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(.vertical) {
                    LazyVStack(spacing: 0) {
                        ForEach(placeVM.myBookmarkedPlaces, id: \.uid) { placeModel in
                            PlaceCell(
                                setPlaceModel: placeModel,
                                setPlaceCellType: .NOMAL,
                                onClickAdd: {},
                                onClickCell: { _ in }
                            )
                            .onAppear {
                                if placeModel.uid == placeVM.myBookmarkedPlaces.last?.uid {
                                    placeVM.loadMoreBookmarks()
                                }
                            }
                        }

                        if placeVM.isLoadingMoreBookmarks {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                            .padding(.vertical, 16)
                        }
                    }
                }
            }
        }
        .background(Color.getColour(.background_yellow_white))
        .onAppear {
            placeVM.loadMyBookmarkedPlaces()
        }
    }
}

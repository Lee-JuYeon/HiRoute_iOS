//
//  Persistence.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//

import SwiftUI
import MapKit
import CoreLocation
import Foundation
import Combine


struct RootSearchView: View {
   
    @EnvironmentObject private var planVM : PlanViewModel
    @EnvironmentObject private var naviVM : NavigationVM
    @StateObject private var searchVM = SearchViewModel()

    @ViewBuilder
    private func searchTopBar(
        onBack : @escaping () -> Void,
        onSearch : @escaping (String) -> Void
    ) -> some View {
        HStack(
            alignment: VerticalAlignment.center
        ){
            Image("icon_arrow_right")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: ContentMode.fit)
                .scaleEffect(x: -1, y: 1) // 수평 반전
                .foregroundColor(Color.getColour(.label_strong))
                .frame(
                    width: 24,
                    height: 24
                )
                .onTapGesture {
                    onBack()
                }
            
            TextField("추가하고 싶은 장소 검색", text: $planVM.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(1)
                .frame(
                    maxWidth: .infinity
                )
            
            Image("icon_search")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: ContentMode.fit)
                .foregroundColor(Color.getColour(.label_strong))
                .frame(
                    width: 24,
                    height: 24
                )
                .onTapGesture {
                    onSearch(planVM.searchText)
                }
        }
    }
    

    var body: some View {
        VStack(
            alignment : HorizontalAlignment.leading
        ){
            searchTopBar(
                onBack: {
                    naviVM.navigateTo(setDestination: .planDetail)
                },
                onSearch: { searchText in
                    // 여기서 텍스트 검색 로직 구현
                }
            )
            
            // 업소 리스트 (조건부 표시)
            if searchVM.showStoreList {
                StoreListView(
                    stores: searchVM.stores,
                    onStoreSelect: { store in
                        searchVM.selectStore(store)
                    },
                    onClose: {
                        searchVM.hideStoreList()
                    }
                )
                .padding(.horizontal)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            
            CustomMapView(searchVM: searchVM)
        }
    }
}



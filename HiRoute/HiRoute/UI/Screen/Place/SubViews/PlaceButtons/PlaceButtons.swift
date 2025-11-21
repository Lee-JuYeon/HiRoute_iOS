//
//  RouteSplashView.swift
//  HiRoute
//
//  Created by Jupond on 7/5/25.
//
import SwiftUI

struct PlaceButtons : View {
    
    let setModel : PlaceModel
    let onCallBackPlaceNavigation : (AddressModel) -> Void
    let onCallBackAddPlace : (PlaceModel) -> Void
    let onCallBackBookMark : (String) -> Void

    @ViewBuilder
    private func navigationButton() -> some View {
        Button {
            onCallBackPlaceNavigation(setModel.address)
        } label: {
            VStack(alignment: HorizontalAlignment.center, spacing: 8) {
                Image("icon_pin")
                    .resizable()
                    .foregroundColor(Color.getColour(.label_strong))
                    .aspectRatio(contentMode: ContentMode.fit)
                    .frame(width: 24, height: 24)

                Text("길찾기")
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_strong))
            }
        }
        .frame(maxWidth: .infinity) // 버튼 너비를 최대한 늘림
    }
    
    @ViewBuilder
    private func addPlaceButton() -> some View {
        Button {
            onCallBackAddPlace(setModel)
        } label: {
            VStack(alignment: HorizontalAlignment.center, spacing: 8) {
                Image("icon_pin")
                    .resizable()
                    .foregroundColor(Color.getColour(.label_strong))
                    .aspectRatio(contentMode: ContentMode.fit)
                    .frame(width: 24, height: 24)

                Text("일정에 추가")
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_strong))
                
            }
        }
        .frame(maxWidth: .infinity) // 버튼 너비를 최대한 늘림
    }
    
    @ViewBuilder
    private func bookMarkButton() -> some View {
        Button {
            onCallBackBookMark(setModel.uid)
        } label: {
            VStack(alignment: HorizontalAlignment.center, spacing: 8) {
                Image("icon_bookmark_off")
                    .resizable()
                    .foregroundColor(Color.getColour(.label_strong))
                    .aspectRatio(contentMode: ContentMode.fit)
                    .frame(width: 24, height: 24)

                Text("북마크")
                    .font(.system(size: 14))
                    .foregroundColor(Color.getColour(.label_strong))
                
            }
        }
        .frame(maxWidth: .infinity) // 버튼 너비를 최대한 늘림
    }
    
    var body: some View {
        HStack(alignment: VerticalAlignment.center, spacing: 0){
            navigationButton()
            addPlaceButton()
            bookMarkButton()
        }
        .frame(maxWidth: .infinity)
    }
}

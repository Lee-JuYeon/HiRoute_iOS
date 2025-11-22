//
//  FlexibleChipLayout.swift
//  HiRoute
//
//  Created by Jupond on 7/7/25.
//
import SwiftUI

struct PlaceAddressView: View {
    
    let address : AddressModel
    let onCallBackCopyAddress : (AddressModel) -> Void
    
    var body: some View {
        HStack(
            alignment: VerticalAlignment.center,
            spacing: 4
        ) {
            Image("icon_pin")
                .renderingMode(.template)
                .resizable()
                .foregroundColor(Color.getColour(.label_strong))
                .aspectRatio(contentMode: ContentMode.fit)
                .frame(width: 20, height: 20)

            Text(address.fullAddress)
                .font(.system(size: 14))
                .foregroundColor(Color.getColour(.label_strong))
                .fontWeight(.bold)
                .lineLimit(1)
                .multilineTextAlignment(.leading)
            
            Button {
                onCallBackCopyAddress(address)
            } label: {
                Text("주소 복사")
                    .font(.system(size: 12))
                    .foregroundColor(Color.getColour(.status_positive))
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(
            EdgeInsets(top: 0, leading: 12, bottom: 16, trailing: 12)
        )
    }
    
}

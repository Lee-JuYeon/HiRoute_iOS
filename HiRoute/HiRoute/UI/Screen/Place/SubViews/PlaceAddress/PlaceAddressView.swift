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
                .resizable()
                .foregroundColor(Color.getColour(.label_strong))
                .aspectRatio(contentMode: ContentMode.fit)
                .frame(width: 12, height: 12)

            Text(address.fullAddress)
                .font(.system(size: 12))
                .foregroundColor(Color.getColour(.label_normal))
            
            Button {
                onCallBackCopyAddress(address)
            } label: {
                Text("주소 복사")
                    .font(.system(size: 12))
                    .foregroundColor(Color.getColour(.status_positive))
            }
        }
        .padding(
            EdgeInsets(top: 0, leading: 12, bottom: 16, trailing: 12)
        )
    }
    
}

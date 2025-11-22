//
//  FullSizeImageListView.swift
//  HiRoute
//
//  Created by Jupond on 11/23/25.
//

import SwiftUI

struct FullSizeImageListView : View {
    
    let setImageList : [ReviewImageModel]
    @Environment(\.presentationMode) var presentationMode
    @State private var currentIndex = 0

    var body: some View {
        ZStack(alignment: .topLeading){
            TabView(selection: $currentIndex) {
                ForEach(0..<setImageList.count, id: \.self) { index in
                    let imageModel = setImageList[index]
                    ServerImageView(setImageURL: imageModel.imageURL)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            
            // 닫기 버튼
            ZStack {
                Circle()
                    .fill(Color.getColour(.label_strong))
                
                Circle()
                    .stroke(Color.getColour(.label_alternative), lineWidth: 1)
                
                Image("icon_close")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
                    .foregroundColor(Color.getColour(.background_white))
            }
            .frame(width: 32, height: 32)
            .padding(EdgeInsets(top: 44, leading: 16, bottom: 0, trailing: 0))
            .onTapGesture {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .background(Color.getColour(.label_strong))
    }
}


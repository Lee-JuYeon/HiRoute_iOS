//
//  ReviewCell.swift
//  HiRoute
//
//  Created by Jupond on 11/20/25.
//

import SwiftUI

struct ReviewCell : View {
    
    private var model : ReviewModel
    private var callBackOption : (String) -> Void
    private var callBackUseful : (String) -> Void
    init(
        setModel : ReviewModel,
        onCallBackOption : @escaping (String) -> Void,
        onCallBackUseful : @escaping (String) -> Void
    ){
        self.model = setModel
        self.callBackOption = onCallBackOption
        self.callBackUseful = onCallBackUseful
    }
    
    @State private var openImageView : Bool = false
    var body: some View {
        VStack(alignment: HorizontalAlignment.leading, spacing: 0){
            HStack(alignment: VerticalAlignment.center, spacing: 0){
                Text("\(model.userName)")
                Image("icon_options")
                    .onTapGesture {
                        callBackOption(model.reviewUID)
                    }
            }
            
            HStack(alignment: VerticalAlignment.center, spacing: 0){
                Text("도움 돼요")
                Image("icon_thumb_fill")
                    .onTapGesture {
                        callBackUseful(model.userUID)
                    }
                Text("\(model.usefulList.count)")
                Text("\(model.visitDate) 방문")
            }
            
            ScrollView(.horizontal){
                ForEach(model.images, id: \.userUID){ imageModel in
                    Image(imageModel.imageURL)
                        .frame(
                            height: 103
                        )
                        .background(Color.getColour(.label_alternative))
                        .onTapGesture {
                            openImageView = true
                        }
                }
            }
            
            Text(model.reviewText)
        }
//        .fullScreenCover(isPresented: $openImageView) {
//            <#code#>
//        }
    }
}

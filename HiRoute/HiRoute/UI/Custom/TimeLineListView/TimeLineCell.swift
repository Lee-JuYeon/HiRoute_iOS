//
//  SheetReply.swift
//  HiRoute
//
//  Created by Jupond on 7/1/25.
//

import SwiftUI

struct SheetReply : View {
//
//    @ViewBuilder
//    private func cell(_ replyModel : ReplyModel) -> some View{
//        HStack(alignment: VerticalAlignment.top) {
//            SelfieView(
//                imageURL: feedVM.currentFeedModel?.simpleUserModel.userSelfieURL,
//                size: 14,
//                placeholderIcon: "icon_placeholder",
//                backgroundColor: Color.blue
//            )
//        }
//    }                                              
//    @State private var replyText = ""
//    private var replyHint = "댓글 추가"
//    @ViewBuilder
//    private func editText() -> some View{
//        HStack(alignment: VerticalAlignment.center){
//            SelfieView(
//                imageURL: feedVM.currentFeedModel?.simpleUserModel.userSelfieURL,
//                size: 20,
//                placeholderIcon: "icon_placeholder",
//                backgroundColor: Color.blue
//            )
//            
//            HStack(){
//                TextField(replyHint, text :$replyText)
//                    .keyboardType(.default)
//                    .autocapitalization(.none)
//                    .disableAutocorrection(true)
//                
////                Group{
////                    if $replyText.lowercased.count == 0 {
////                        Button {
////                            print("텍스트가 없는 경우")
////                        } label: {
////                            <#code#>
////                        }
////                    }else{
////                        Button {
////                            print("텍스트가 있는 경우")
////                        } label: {
////                            Image("icon_send")
////                                .foregroundColor(Color.white)
////                                .overlay {
////                                    Rectangle()
////                                        .
////                                }
////                        }
////                    }
////                }
//            }
//        }
//    }

    var body: some View {
        VStack(alignment: HorizontalAlignment.leading){
            Text("SheetReply 뷰")
//            ScrollView(Axis.Set.vertical) {
//                LazyVStack(alignment: HorizontalAlignment.leading) {
//                    if let list = feedVM.currentFeedModel?.replyList {
//                        ForEach(list, id: \.self){ replyModel in
//                           ServerImageView(
//                            setImageURL: feedVM.currentFeedModel?.simpleUserModel.userSelfieURL ?? "",
//                            setImageSize: 180,
//                            setPlaceHolder: "icon_placeholder",
//                            setCornerRadius: 0
//                           )
//                        }
//                    } else {
//                        Text("작성된 댓글이 없습니다.")
//                    }
//                }
//            }
//            editText()
        }
        .frame(
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: Alignment.topLeading
        )
        .background(Color.yellow)
    }
}

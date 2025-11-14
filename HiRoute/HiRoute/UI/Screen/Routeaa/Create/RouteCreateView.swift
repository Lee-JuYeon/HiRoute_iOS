//
//  RouteCreateView.swift
//  HiRoute
//
//  Created by Jupond on 7/5/25.
//

import SwiftUI


struct RouteCreateView : View {
   
    
    @State private var tabViewIndex = 0
    
    var body: some View {
        VStack(){
            HStack(alignment: VerticalAlignment.center, spacing: 8){
                Button {
//                    routeDestination = .splash
                } label: {
                    HStack(alignment: .center, spacing: 8) {
                        Image("icon_arrow_right")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: ContentMode.fit)
                            .scaleEffect(x: -1, y: 1) // 수평 반전
                            .foregroundColor(Color.getColour(.label_strong))
                            .frame(
                                width: 12,
                                height: 24
                            )
                        Text("루트 짜기")
                            .font(.system(size: 18))
                            .foregroundColor(Color.getColour(.label_strong))
                            .fontWeight(.bold)
                    }
                    .padding(.vertical, 8)
                }

                
                Spacer()
                
                
                Button {
//                    isShowRouteView = false
                } label: {
                    Image("icon_close")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: ContentMode.fit)
                        .foregroundColor(Color.getColour(.label_strong))
                        .frame(
                            width: 24,
                            height: 24
                        )
                }
            }
            
           
            RouteTabView(
                tabViewIndex: $tabViewIndex, totalPage: 2
            ) {
                Text("임시로 막아놓기")
//                switch tabViewIndex {
//                case 0 :
//                    RouteCreateFirstView(selectedIndex: $tabViewIndex)
//                case 1 :
//                    RouteCreateSecondView(selectedIndex: $tabViewIndex, isShowRouteView: $isShowRouteView)
//                default:
//                    RouteCreateFirstView(selectedIndex: $tabViewIndex)
//                }
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        .background(Color.getColour(.background_white))

    }
}


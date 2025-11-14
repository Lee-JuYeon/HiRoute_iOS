//
//  RouteSplashView.swift
//  HiRoute
//
//  Created by Jupond on 7/5/25.
//
import SwiftUI

struct RouteSplashView : View {
    
    @Binding var routeDestination : RouteDestination
    @Binding var isShowRouteView : Bool
    
    var body: some View {
        VStack(){
            HStack(alignment: VerticalAlignment.center, spacing: 8){
                Image("icon_arrow_right")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: ContentMode.fill)
                    .frame(width: 12, height: 24)
                    .scaleEffect(x: -1, y: 1) // 수평 반전
                    
                Text("루트 짜기")
                    .font(.system(size: 18))
                    .foregroundColor(Color.black)
                    .fontWeight(.bold)
            }
            .onTapGesture {
                print("메인화면 이전")
                isShowRouteView.toggle()
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .padding(.vertical, 8)
            
            Text("어떤 방법으로\n루트를 짜볼까요?")
                .font(.system(size: 24))
                .foregroundColor(Color.black)
                .fontWeight(.bold)
                .padding(.vertical, 40)
            
            
            Button(action: {
                routeDestination = RouteDestination.create

            }) {
                Text("직접 루트 짜기")
                    .font(.system(size: 24))
                    .foregroundColor(Color.black)
                    .fontWeight(.bold)
                    .padding(.vertical, 40)
            }
            
            Button(action: {
//                routeDestination = RouteDestination.gatcha

            }) {
                Text("루트 가챠하기")
                    .font(.system(size: 24))
                    .foregroundColor(Color.black)
                    .fontWeight(.bold)
                    .padding(.vertical, 40)
            }
            
            
            Spacer()
            
            Button(action: {
                routeDestination = RouteDestination.create
            }) {
                Text("루트 짜기")
                    .font(.system(size: 24))
                    .foregroundColor(Color.white)
                    .fontWeight(.bold)
                    .padding(.vertical, 40)
            }
            .frame(
                maxWidth: .infinity,
                alignment: .center
            )
            .background(Color.black)
            .cornerRadius(10)
            
        }
        .padding(16)
    }
}


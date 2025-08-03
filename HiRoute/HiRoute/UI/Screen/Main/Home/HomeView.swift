//
//  HomeView.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

struct HomeView: View {
   
    @EnvironmentObject private var planVM : PlanViewModel
    @EnvironmentObject private var naviVM : NavigationVM
    
    @ViewBuilder
    private func routeButton() -> some View {
        Button(action: {
            naviVM.navigateTo(setDestination: AppDestination.planDetail)
        }) {
            Image("img_route_create")
                .resizable() // 이 부분이 핵심!
                .aspectRatio(contentMode: ContentMode.fit)
                .frame(
                    maxWidth: .infinity
                )
                .frame(height: 113)
                .clipped()
                .background(Color.white)
                .cornerRadius(12)

        }
        .padding(
            EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0)
        )
        .customElevation(.normal)
    }
    
    @ViewBuilder
    private func search() -> some View {
        HStack(alignment: VerticalAlignment.center){
            Button {
                print("검색버튼 눌림")
            } label: {
                Image("icon_search")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: ContentMode.fit)
                    .foregroundColor(Color.getColour(.label_strong))
                   
            }
            .padding(10)
            .frame(width: 44, height: 44)
        }
        .frame(
            maxWidth: .infinity,
            alignment: Alignment.trailing
        )
    }
    
   
  
   
    private let hotPlaceTitle : String = "지금 인기 있는 장소"
    private let placetitle : String = "지역 맞춤 장소"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                
               
                search()
                
                RouteButton {
                    naviVM.navigateTo(setDestination: AppDestination.planDetail)
                }
                
                TrendPlaceSection(
                    setTitle: hotPlaceTitle,
                    setList: planVM.trendRoutes,
                    setOnClickCell: { routeModel in
                       
                    },
                    setOnClickBookMark: { routeUid in
                        
                    }
                )
               
                // 인기 루트 섹션
                LocalisedPlaceSection(
                    getTitle: placetitle,
                    getOnClickTotal: {
                        
                    },
                    getList: planVM.localisedRoutes,
                    getOnClickCell: { placeModel in
                       
                    },
                    getOnClickBookMark: { isBookMarked in
                        
                    }
                )
              
            }

        }
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
        .background(Color.getColour(.background_yellow_white))
       

    }
    
}


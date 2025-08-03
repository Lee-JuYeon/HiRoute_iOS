//
//  HomePlaceCell 3.swift
//  HiRoute
//
//  Created by Jupond on 7/17/25.
//

import SwiftUI

struct RootDetailView : View {
    @EnvironmentObject private var planVM : PlanViewModel
    @EnvironmentObject private var naviVM : NavigationVM
    
    @State private var selectedTab = 0
    @State var isShowScheduleSheet : Bool = false
    
    let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy.MM.dd"
        return df
    }()

    
    var body: some View {
        VStack(alignment: HorizontalAlignment.leading){
            RootDetailTopBarView(
                setOnClickBack: {},
                setOnClickShare: {},
                setOnClickSettings: {
                    
                }
            )
             
            RootDetailCountingTextView()
            RootDetailTitleView()
           
            
            RootDetailChartView(
                setDate: formatter.string(from: planVM.myPlans[0].meetingDate),
                setAddress: planVM.myPlans[0].meetingAddress.gungu,
                setRootStyle: nil,
                setWeather: nil,
                setOnClick: {
                    isShowScheduleSheet = true
                }
            )
            
            CustomTabView(
                setTabViewStyle: .TabView,
                setTabBackgroundColour: Color.getColour(.background_yellow_white),
                setTabItemModels: [
                    CustomTabView.CustomTabItemModel(title: "타임라인"),
                    CustomTabView.CustomTabItemModel(title: "지도"),
                ],
                setSelectedIndex: $selectedTab
            ) { index in
                switch index {
                case 0:
                    TimeLineListView(
                        setPlanModel: planVM.myPlans[0],
                        setOnClickRouteEdit: {
                            
                        },
                        setOnClickRouteAdd: {
                            // 장소검색 액티비티로 이동
                            naviVM.navigateTo(setDestination: .search)
                        }
                    )
                case 1:
                    myMapVIew()
                default:
                    TimeLineListView(
                        setPlanModel: planVM.myPlans[0],
                        setOnClickRouteEdit: {
                            
                        },
                        setOnClickRouteAdd: {
                            
                        }
                    )
                }
            }
            
        }
        .background(Color.getColour(.background_yellow_white))
        .frame(
            alignment: .topLeading
        )
        .bottomSheet(
            isOpen: $isShowScheduleSheet,
            setContent: {
                SheetRootDetailScheduleChangeView(
                    setOnClickChangeSchedule: {
                        
                    },
                    setOnClickChangeSpot: {
                        
                    },
                    setOnClickChangeRootStyle: {
                        
                    },
                    setOnClickDeleteSchedule: {
                        
                    }
                )
            }
        )
    }
}


struct myMapVIew : View {
    var body: some View {
        Text("ㅈㅣㄷㅓㅓㅓ ㅂㅠ")

    }
}

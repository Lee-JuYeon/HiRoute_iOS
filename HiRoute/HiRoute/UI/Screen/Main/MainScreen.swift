//
//  MainScreen.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

struct MainScreen: View {
    @State private var selectedTab: MainDestination = .home
    @EnvironmentObject private var navigationVM : NavigationVM
    @EnvironmentObject private var planVM : PlanViewModel
    @EnvironmentObject private var searchVM : SearchViewModel
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .environmentObject(navigationVM)
                .environmentObject(planVM)
                .environmentObject(searchVM)
                .tabItem {
//                    Image(systemName: MainDestination.home.icon)
//                    Text(MainDestination.home.title)
                    Image(systemName: "map.fill")
                    Text("지도")
                }
                .tag(MainDestination.home)
            
//            ScheduleView()
//                .environmentObject(navigationVM)
//                .navigationViewStyle(StackNavigationViewStyle())
//                .tabItem {
//                    Image(systemName: MainDestination.feed.icon)
//                    Text(MainDestination.feed.title)
//                }
//                .tag(MainDestination.feed)
//            
//            ScheduleView()
//                .navigationViewStyle(StackNavigationViewStyle())
//                .tabItem {
//                    Image(systemName: MainDestination.schedule.icon)
//                    Text(MainDestination.schedule.title)
//                }
//                .tag(MainDestination.schedule)
            
            MyPageView()
                .navigationViewStyle(StackNavigationViewStyle())
                .tabItem {
                    Image(systemName: MainDestination.myPage.icon)
                    Text(MainDestination.myPage.title)
                }
                .tag(MainDestination.myPage)
        }
        .onAppear {
            planVM.loadInitialData()
        }
    }
}

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
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .environmentObject(navigationVM)
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
        }
    }
}

//
//  MainScreen.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

struct MainScreen: View {
    @State private var selectedTab: MainDestination = .map
    @EnvironmentObject private var navigationVM : NavigationVM
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .environmentObject(navigationVM)
                .tabItem {
                    Image(systemName: MainDestination.map.icon)
                    Text(MainDestination.map.title)
                }
                .tag(MainDestination.map)
            
            ScheduleView()
                .environmentObject(navigationVM)
                .navigationViewStyle(StackNavigationViewStyle())
                .tabItem {
                    Image(systemName: MainDestination.route.icon)
                    Text(MainDestination.route.title)
                }
                .tag(MainDestination.route)
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

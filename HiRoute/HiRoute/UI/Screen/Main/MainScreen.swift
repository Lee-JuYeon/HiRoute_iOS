//
//  MainScreen.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

struct MainScreen: View {
    @State private var selectedTab: MainDestination = .home
    
    let onNavigateToFeedCreate: () -> Void
    let onNavigateToFeedDetail: () -> Void
    let onNavigateToScheduleCreate: () -> Void
    let onNavigateToScheduleGacha: () -> Void
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(
                onNavigateToScheduleCreate: onNavigateToScheduleCreate,
                onNavigateToScheduleGacha: onNavigateToScheduleGacha
            )
            .tabItem {
                Image(systemName: MainDestination.home.icon)
                Text(MainDestination.home.title)
            }
            .tag(MainDestination.home)
            
            FeedView(
                onNavigateToFeedCreate: onNavigateToFeedCreate,
                onNavigateToFeedDetail: onNavigateToFeedDetail
            )
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: MainDestination.feed.icon)
                Text(MainDestination.feed.title)
            }
            .tag(MainDestination.feed)
            
            ScheduleView()
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: MainDestination.schedule.icon)
                Text(MainDestination.schedule.title)
            }
            .tag(MainDestination.schedule)
            
            MyPageView()
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                Image(systemName: MainDestination.myPage.icon)
                Text(MainDestination.myPage.title)
            }
            .tag(MainDestination.myPage)
        }
    }
}

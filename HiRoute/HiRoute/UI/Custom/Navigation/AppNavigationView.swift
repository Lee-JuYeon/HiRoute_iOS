//
//  AppNavigationView.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//
import SwiftUI

struct AppNavigationView: View {
    @State private var currentAppDestination: AppDestination = .main
    @State private var showingFeedCreate = false
    @State private var showingFeedDetail = false
    @State private var showingScheduleCreate = false
    @State private var showingScheduleGacha = false
    
    var body: some View {
        NavigationView {
            Group {
                switch currentAppDestination {
                case .splash:
                    SplashScreen()
                case .auth:
                    AuthNavigationView()
                case .main:
                    MainScreen(
                        onNavigateToFeedCreate: { showingFeedCreate = true },
                        onNavigateToFeedDetail: { showingFeedDetail = true },
                        onNavigateToScheduleCreate: { showingScheduleCreate = true },
                        onNavigateToScheduleGacha: { showingScheduleGacha = true }
                    )
                default:
                    MainScreen(
                        onNavigateToFeedCreate: { showingFeedCreate = true },
                        onNavigateToFeedDetail: { showingFeedDetail = true },
                        onNavigateToScheduleCreate: { showingScheduleCreate = true },
                        onNavigateToScheduleGacha: { showingScheduleGacha = true }
                    )
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showingFeedCreate) {
            FeedCreateScreen()
        }
        .sheet(isPresented: $showingFeedDetail) {
            FeedDetailScreen()
        }
        .sheet(isPresented: $showingScheduleCreate) {
            ScheduleCreateScreen()
        }
        .sheet(isPresented: $showingScheduleGacha) {
            ScheduleGachaScreen()
        }
    }
}

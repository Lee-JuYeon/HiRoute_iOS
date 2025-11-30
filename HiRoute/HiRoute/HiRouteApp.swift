//
//  HiRouteApp.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//

import SwiftUI

@main
struct HiRouteApp: App {
    
    @StateObject private var scheduleVM = ScheduleViewModel()
    @StateObject private var localVM = LocalVM()
    
  
    var body: some Scene {
        WindowGroup {
            AppNavigationView()
                .environmentObject(scheduleVM)
                .environmentObject(localVM)  // ✅ 전역 주입

        }
    }
}



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
    
  
    var body: some Scene {
        WindowGroup {
            AppNavigationView()
                .environmentObject(scheduleVM)

//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}



//
//  HiRouteApp.swift
//  HiRoute
//
//  Created by Jupond on 6/3/25.
//

import SwiftUI

@main
struct HiRouteApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

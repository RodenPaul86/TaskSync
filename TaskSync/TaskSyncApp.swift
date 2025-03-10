//
//  TaskSyncApp.swift
//  TaskSync
//
//  Created by Paul  on 11/3/24.
//

import SwiftUI
import UserNotifications

@main
struct TaskSyncApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

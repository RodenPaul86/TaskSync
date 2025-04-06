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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Task.self)
    }
}

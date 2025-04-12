//
//  TaskSyncApp.swift
//  TaskSync
//
//  Created by Paul  on 11/3/24.
//

import SwiftUI
import UserNotifications
import RevenueCat

@main
struct TaskSyncApp: App {
    @StateObject var appSubModel = appSubscriptionModel()
    
    init() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: apiKeys.revenueCat)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appSubModel)
        }
        .modelContainer(for: Task.self)
    }
}

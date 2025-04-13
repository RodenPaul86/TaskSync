//
//  TaskSyncApp.swift
//  TaskSync
//
//  Created by Paul  on 11/3/24.
//

import SwiftUI
import UserNotifications
import TipKit
import RevenueCat

@main
struct TaskSyncApp: App {
    @StateObject var appSubModel = appSubscriptionModel()
    
    init() {
        Purchases.logLevel = .error
        Purchases.configure(withAPIKey: apiKeys.revenueCat)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appSubModel)
                .task {
                    //try? Tips.resetDatastore()
                    try? Tips.configure([
                        .datastoreLocation(.applicationDefault)
                    ])
                }
        }
        .modelContainer(for: Task.self)
    }
}

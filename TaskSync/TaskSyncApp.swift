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
    @State private var showComposeOverlay: Bool = false
    @Namespace private var composeNamespace

    @StateObject var appSubModel = appSubscriptionModel()
    
    init() {
        Purchases.logLevel = .error
        Purchases.configure(withAPIKey: apiKeys.revenueCat)
    }
    
    var body: some Scene {
        WindowGroup {
            SchemeHostView {
                ContentView(showComposeOverlay: $showComposeOverlay, composeNamespace: composeNamespace)
                    .environmentObject(appSubModel)
                    .environment(AppRouter())
                    .task {
                        //try? Tips.resetDatastore()
                        try? Tips.configure([
                            .datastoreLocation(.applicationDefault)
                        ])
                    }
            }
        }
        .modelContainer(for: TaskData.self)
    }
}

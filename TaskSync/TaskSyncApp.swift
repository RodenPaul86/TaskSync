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
    
    init() {
        // Set up the notification center delegate
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    NotificationManager.shared.requestNotificationPermissions()
                }
        }
    }
}

// Notification Delegate to handle notifications in the foreground
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    private override init() {} // Singleton
    
    // Handle notifications while the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show the notification as a banner and play sound
        completionHandler([.banner, .sound])
    }
}

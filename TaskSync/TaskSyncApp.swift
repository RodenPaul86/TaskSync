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
                    NotificationManager.shared.requestNotificationPermissions { granted in
                        if granted {
                            // Permission granted: schedule the notification
                            //let time = Date(timeIntervalSince1970: notificationTime)
                            //NotificationManager.shared.scheduleDailyNotification(at: time, soundName: "\(customSound).wav")
                        } else {
                            // Permission denied: update the toggle or show an alert
                            DispatchQueue.main.async {
                                //notificationsEnabled = false // Update the toggle state
                                AlertHelper.showGlobalAlert(
                                    title: "Enable Notifications",
                                    message: "You denied notification permissions. Enable them in settings to receive reminders."
                                )
                            }
                        }
                    }
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

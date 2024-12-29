//
//  NotificationManager.swift
//  TaskSync
//
//  Created by Paul  on 11/17/24.
//

import UserNotifications
import CoreData
import UIKit

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {} // Singleton
    
    // MARK: - General Notification Permissions
    func requestNotificationPermissions(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permissions: \(error.localizedDescription)")
                AlertHelper.showGlobalAlert(title: "Error", message: "An issue occurred while requesting notification permissions. Please try again later or contact support.")
            }
            DispatchQueue.main.async {
                completion(granted)
                if !granted {
                    AlertHelper.showGlobalAlert(title: "Enable Notifications", message: "Notifications help you stay informed about your upcoming tasks.")
                }
            }
        }
    }
    
    // Enable or disable all notifications
    func toggleNotifications(enable: Bool) {
        if enable {
            requestNotificationPermissions { granted in
                if granted {
                    print("Notifications enabled")
                } else {
                    print("Notifications not granted by the user.")
                }
            }
        } else {
            cancelAllNotifications()
            print("Notifications disabled")
        }
    }
    
    // Cancel a specific notification
    func cancelNotification(withIdentifier identifier: String) {
        guard !identifier.isEmpty else {
            print("Invalid notification ID: \(identifier). Skipping cancellation.")
            return
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("Notification with ID \(identifier) canceled.")
    }
    
    // MARK: - Task-Specific Notifications
    func scheduleNotification(for task: String, at date: Date, taskContext: NSManagedObjectContext, taskID: NSManagedObjectID) {
        guard UserDefaults.standard.bool(forKey: "allowNotifications") else {
            print("Notifications are disabled; task notification not scheduled.")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = "It's time for: \(task)"
        
        // Retrieve the selected sound from UserDefaults
        let soundName = UserDefaults.standard.string(forKey: "alertSound") ?? "Default"
        if soundName == "Default" {
            content.sound = .default
        } else {
            let soundFileName = "\(soundName).wav"
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundFileName))
        }
        
        // Configure the trigger for the notification
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date),
            repeats: false
        )
        
        let notificationID = UUID().uuidString
        let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
        
        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule task notification: \(error.localizedDescription)")
            } else {
                print("Task notification scheduled successfully with sound: \(soundName).")
                DispatchQueue.main.async {
                    do {
                        // Update the task object in Core Data
                        let taskObject = try taskContext.existingObject(with: taskID)
                        taskObject.setValue(true, forKey: "hasNotification")
                        taskObject.setValue(notificationID, forKey: "notificationID")
                        try taskContext.save()
                        print("Task updated with notification flag and ID.")
                    } catch {
                        print("Failed to update task in Core Data: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func cancelTaskNotification(for taskID: String) {
        cancelNotification(withIdentifier: taskID)
    }
}

extension NotificationManager {
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        print("All notifications have been canceled.")
    }
}

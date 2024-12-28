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
    
    private init() {} // Private initializer to enforce singleton pattern
    
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
    
    func cancelNotification(withIdentifier identifier: String) {
        guard !identifier.isEmpty else {
            print("Invalid notification ID: \(identifier). Skipping cancellation.")
            return
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("Notification with ID \(identifier) canceled.")
    }
    
    // MARK: - Daily Notifications
    func scheduleDailyNotification(at time: Date, soundName: String = "default") {
        cancelNotification(withIdentifier: "dailyReminder")
        
        let content = UNMutableNotificationContent()
        content.title = "Daily Reminder"
        content.body = "Check your tasks for today!"
        content.sound = soundName == "default" ? .default : UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName))
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule daily reminder: \(error.localizedDescription)")
            } else {
                print("Daily reminder scheduled at \(time).")
            }
        }
    }
    
    // MARK: - Task-Specific Notifications
    func scheduleNotification(for task: String, at date: Date, taskObject: NSManagedObjectContext, taskID: NSManagedObjectID) {
        guard UserDefaults.standard.bool(forKey: "notificationsEnabled") else {
            print("Notifications are disabled; task notification not scheduled.")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = "It's time for: \(task)"
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date),
            repeats: false
        )
        
        let notificationID = UUID().uuidString
        let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule task notification: \(error.localizedDescription)")
            } else {
                print("Task notification scheduled successfully.")
                DispatchQueue.main.async {
                    do {
                        let task = try taskObject.existingObject(with: taskID)
                        task.setValue(true, forKey: "hasNotification")
                        task.setValue(notificationID, forKey: "notificationID")
                        try taskObject.save()
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

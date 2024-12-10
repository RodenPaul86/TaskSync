//
//  NotificationManager.swift
//  TaskSync
//
//  Created by Paul  on 11/17/24.
//

import UserNotifications
import CoreData

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {} // Private initializer to enforce singleton pattern
    
    // Function to request notification permissions
    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permissions: \(error.localizedDescription)")
            }
            if granted {
                print("Notification permissions granted.")
            } else {
                print("Notification permissions denied.")
            }
        }
    }
    
    // Function to schedule a local notification and update Core Data
    func scheduleNotification(for task: String, at date: Date, taskObject: NSManagedObjectContext, taskID: NSManagedObjectID) {
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = "It's time for: \(task)"
        content.sound = .default
        
        // Create a trigger for the notification
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date),
            repeats: false
        )
        
        // Create the request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully.")
                
                // Update Core Data to set hasNotification to true
                DispatchQueue.main.async {
                    do {
                        let task = try taskObject.existingObject(with: taskID)
                        task.setValue(true, forKey: "hasNotification")
                        try taskObject.save()
                        print("Task updated with notification flag.")
                    } catch {
                        print("Failed to update task in Core Data: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

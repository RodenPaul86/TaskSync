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
    
    // Function to request notification permissions
    func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permissions: \(error.localizedDescription)")
                AlertHelper.showGlobalAlert(title: "Error", message: "An issue occurred while requesting notification permissions. Please try again later or contact support.")
            }
            if granted {
                print("Notification permissions granted.")
            } else {
                print("Notification permissions denied.")
                AlertHelper.showGlobalAlert(title: "Enable Notifications", message: "Notifications help you stay informed about your upcoming tasks.")
            }
        }
    }
    
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
        let notificationID = UUID().uuidString
        let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
        
        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully.")
                
                // Update Core Data to save the notification ID and set hasNotification to true
                DispatchQueue.main.async {
                    do {
                        let task = try taskObject.existingObject(with: taskID)
                        task.setValue(true, forKey: "hasNotification")
                        task.setValue(notificationID, forKey: "notificationID")  // Save notification ID here
                        try taskObject.save()
                        print("Task updated with notification flag and ID.")
                    } catch {
                        print("Failed to update task in Core Data: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    // Function to cancel a notification using its identifier
    func cancelNotification(for taskID: String) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            // Find the notification with the matching identifier
            let identifiersToCancel = requests.filter { $0.identifier == taskID }.map { $0.identifier }
            
            // Remove the notification
            if !identifiersToCancel.isEmpty {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToCancel)
                print("Notification with ID \(taskID) canceled.")
            }
        }
    }
}

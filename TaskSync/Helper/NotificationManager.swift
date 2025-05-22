//
//  NotificationManager.swift
//  TaskSync
//
//  Created by Paul  on 5/22/25.
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    private var taskMessages = [
        "You have a task due!",
        "Hey, you've got a task coming up!",
        "Task time! You're up.",
        "Just a heads-up: You’ve got something due.",
        "Reminder: Task deadline approaching.",
        "Time to knock out that task!",
        "Crush this task—it’s due!",
        "Let’s get that task done!",
        "Task due soon—don’t forget!",
        "A task is due."
    ]
    
    // Request permission to show notifications
    func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                UserDefaults.standard.set(granted, forKey: "notificationsEnabled")
                completion?(granted)
            }
        }
    }
    
    // Random Message
    private func getRandomTaskMessage() -> String {
        taskMessages.randomElement() ?? "You have a task due!"
    }
    
    // Schedule a notification for a future task
    func scheduleNotification(for task: TaskData) {
        guard UserDefaults.standard.bool(forKey: "notificationsEnabled") else {
            print("Notifications are disabled.")
            return
        }
        
        guard task.creationDate > Date() else {
            print("Skipping notification for past task: \(task.taskTitle)")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = task.taskTitle
        content.body = task.taskDescription.isEmpty ? getRandomTaskMessage() : task.taskDescription
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: task.creationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let identifier = task.id?.uuidString ?? UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            } else {
                print("Scheduled notification for task: \(task.taskTitle)")
            }
        }
    }
    
    // Optional: Cancel notification
    func cancelNotification(for taskID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [taskID.uuidString])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [taskID.uuidString])
    }
}

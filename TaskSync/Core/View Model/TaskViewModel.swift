//
//  TaskViewModel.swift
//  TaskSync
//
//  Created by Paul on 11/3/24.
//

import SwiftUI
import CoreData
import Combine

class TaskViewModel: ObservableObject {
    
    // MARK: Current week
    @Published var currentWeek: [Date] = []
    
    // MARK: Current day
    @Published var currentDay: Date = Date()
    
    // MARK: Filtering Today Tasks
    @Published var filteredTasks: [Task]?
    
    // MARK: New Task View
    @Published var addNewTask: Bool = false
    
    // MARK: Edit Data
    @Published var editTask: Task?
    
    // MARK: Intializing
    init() {
        // Retrieve the "Start of the Week" setting from UserDefaults or use a default value
        let startOfWeek = UserDefaults.standard.string(forKey: "startOfWeek") ?? "Sunday"
        fetchCurrentWeek(startOfWeek: startOfWeek)
    }
    
    // MARK: Fetch Current Week
    func fetchCurrentWeek(startOfWeek: String) {
        let today = Date()
        var calendar = Calendar.current
        
        // Determine the user's start of the week
        switch startOfWeek {
        case "Monday":
            calendar.firstWeekday = 2 // Monday
        case "Tuesday":
            calendar.firstWeekday = 3 // Tuesday
        case "Wednesday":
            calendar.firstWeekday = 4 // Wednesday
        case "Thursday":
            calendar.firstWeekday = 5 // Thursday
        case "Friday":
            calendar.firstWeekday = 6 // Friday
        case "Saturday":
            calendar.firstWeekday = 7 // Saturday
        default:
            calendar.firstWeekday = 1 // Sunday (default)
        }
        
        // Find the week interval based on the custom calendar
        guard let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: today),
              let firstWeekDay = calendar.date(byAdding: .day, value: 0, to: weekInterval.start) else { return }
        
        currentWeek = [] // Clear the existing week data
        
        (0...10).forEach { day in
            if let weekday = calendar.date(byAdding: .day, value: day, to: firstWeekDay) {
                currentWeek.append(weekday)
            }
        }
    }
    
    // MARK: Extraction Date
    func extractDate(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    // MARK: Checking if current date is today
    func isToday(date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(currentDay, inSameDayAs: date)
    }
    
    // MARK: Checking if the currentHour is task Hour
    func isCurrentHour(date: Date) -> Bool {
        let calendar = Calendar.current
        let taskHour = calendar.component(.hour, from: date)
        let currentHour = calendar.component(.hour, from: Date())
        let isSameDay = calendar.isDateInToday(date)
        
        return taskHour == currentHour && isSameDay
    }
    
    // MARK: Filter Tasks for Today
    func filterTasksForToday(tasks: [Task]) {
        let calendar = Calendar.current
        filteredTasks = tasks.filter { task in
            guard let taskDate = task.taskDate else { return false }
            return calendar.isDate(taskDate, inSameDayAs: currentDay)
        }
    }
}

// MARK: Extension for auto-deletion
extension TaskViewModel {
    func autoDeleteOldTasks(context: NSManagedObjectContext) {
        // Fetch all tasks
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            let tasks = try context.fetch(fetchRequest)
            let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date()
            
            for task in tasks {
                if let taskDate = task.taskDate, taskDate < oneWeekAgo {
                    if task.hasNotification && ((task.notificationID?.isEmpty) == nil) {
                        // Cancel the notification if it's scheduled
                        NotificationManager.shared.cancelNotification(withIdentifier: task.notificationID ?? "")
                        
                        // Set the hasNotification flag to false
                        task.hasNotification = false
                    }
                    context.delete(task)
                }
            }
            
            // Save the context after deleting tasks
            try context.save()
        } catch {
            print("Error fetching or deleting tasks: \(error)")
        }
    }
}

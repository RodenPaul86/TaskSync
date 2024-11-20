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
    
    // MARK: Current Week Days
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
        fetchCurrentWeek()
    }
    
    func fetchCurrentWeek() {
        let today = Date()
        let calendar = Calendar.current
        let week = calendar.dateInterval(of: .weekOfMonth, for: today)
        
        guard let firstWeekDay = week?.start else { return }
        
        (0...14).forEach { day in
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

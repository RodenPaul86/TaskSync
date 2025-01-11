//
//  TaskViewModel.swift
//  TaskSync
//
//  Created by Paul on 11/3/24.
//

import SwiftUI
import CoreData
import Combine

enum SyncStatus {
    case idle
    case syncing
    case issue
    case delay
    
    var statusText: String {
        switch self {
        case .idle: return "Fully synced"
        case .syncing: return "Syncing in progress..."
        case .issue: return "Sync issue detected"
        case .delay: return "Sync delayed"
        }
    }
}

class TaskViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var tasks: [Task] = [] // All tasks for syncing
    @Published var currentWeek: [Date] = [] // Current week's dates
    @Published var currentDay: Date = Date() // Current day
    @Published var filteredTasks: [Task]? // Filtered tasks for the day
    @Published var addNewTask: Bool = false // For adding new tasks
    @Published var editTask: Task? // For editing tasks
    @Published var syncStatus: SyncStatus = .idle // Sync status tracking
    @AppStorage("lastSyncTime") var lastSyncTime: Date?
    private let persistenceController = PersistenceController.shared
    
    private var cancellables = Set<AnyCancellable>() // For Combine cancellables
    private let container: NSPersistentCloudKitContainer
    
    // MARK: - Initialization
    init(container: NSPersistentCloudKitContainer = PersistenceController.shared.container) {
        self.container = container
        // Retrieve the "Start of the Week" setting from UserDefaults or use a default value
        let startOfWeek = UserDefaults.standard.string(forKey: "startOfWeek") ?? "Sunday"
        fetchCurrentWeek(startOfWeek: startOfWeek)
    }
    
    // MARK: - Fetch Current Week
    func fetchCurrentWeek(startOfWeek: String) {
        let today = Date()
        var calendar = Calendar.current
        
        // Adjust first day of the week based on the user's settings
        switch startOfWeek {
        case "Monday": calendar.firstWeekday = 2
        case "Tuesday": calendar.firstWeekday = 3
        case "Wednesday": calendar.firstWeekday = 4
        case "Thursday": calendar.firstWeekday = 5
        case "Friday": calendar.firstWeekday = 6
        case "Saturday": calendar.firstWeekday = 7
        default: calendar.firstWeekday = 1 // Sunday
        }
        
        // Get the week's interval starting from the specified day
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
    
    // MARK: - Syncing Methods
    func startSyncing() {
        guard syncStatus != .syncing else { return } // Prevent multiple syncs
        syncStatus = .syncing
        
        syncWithiCloud { success, error in
            DispatchQueue.main.async {
                if success {
                    self.completeSync()
                } else {
                    self.syncStatus = .issue
                    if let error = error {
                        print("Sync failed with error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    // Actual iCloud Sync
    func syncWithiCloud(completion: @escaping (Bool, Error?) -> Void) {
        let backgroundContext = persistenceController.container.newBackgroundContext()
        backgroundContext.perform {
            guard backgroundContext.hasChanges else {
                DispatchQueue.main.async { completion(true, nil) }
                return
            }
            
            do {
                try backgroundContext.save()
                backgroundContext.reset()
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(false, error)
                }
            }
        }
    }
    
    // Handle sync issues or delays
    func handleSyncIssue() {
        self.syncStatus = .issue
    }
    
    func handleSyncDelay() {
        self.syncStatus = .delay
    }
    
    // MARK: - Complete Sync
    func completeSync() {
        let context = persistenceController.container.viewContext
        do {
            if context.hasChanges {
                try context.save()
            }
            DispatchQueue.main.async {
                self.syncStatus = .idle
                self.lastSyncTime = Date()
                UserDefaults.standard.set(self.lastSyncTime, forKey: "lastSyncTime")
            }
        } catch {
            DispatchQueue.main.async {
                self.syncStatus = .issue
                print("Sync failed with error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: Formatted last sync time
    func formattedLastSync() -> String {
        guard let lastSync = lastSyncTime else { return "Never" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: lastSync)
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

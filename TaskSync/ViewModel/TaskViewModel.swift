//
//  TaskViewModel.swift
//  TaskSync
//
//  Created by Paul  on 3/8/25.
//

import SwiftUI
import CoreData

class TaskViewModel: ObservableObject {
    @Published var currentTab: String = "Today"
    
    // MARK: New Task Properties
    @Published var openEditTask: Bool = false
    @Published var taskTitle: String = ""
    @Published var taskDescription: String = ""
    @Published var taskColor: String = "Gray"
    @Published var taskDeadline: Date = Date()
    @Published var taskType: String = "Basic"
    @Published var showDatePicker: Bool = false
    @Published var editTask: Task?
    
    // MARK: Adding tasks to CoreData
    func addTask(context: NSManagedObjectContext) -> Bool {
        // MARK: Updating existing datain CoreData
        var task: Task!
        if let editTask = editTask {
            task = editTask
        } else {
            task = Task(context: context)
        }
        
        task.title = taskTitle
        task.color = taskColor
        task.deadline = taskDeadline
        task.type = taskType
        task.isCompleted = false
        
        if let _ = try? context.save() {
            return true
        }
        return false
    }
    
    // MARK: Resetting Data
    func resetTaskData() {
        taskTitle = ""
        taskDescription = ""
        taskColor = "Gray"
        taskDeadline = Date()
        taskType = "Basic"
    }
    
    // MARK: If edit task is available then setting exisiting data
    func setupTask() {
        if let editTask = editTask {
            taskTitle = editTask.title ?? ""
            taskDescription = ""
            taskColor = editTask.color ?? "Gray"
            taskDeadline = editTask.deadline ?? Date()
            taskType = editTask.type ?? "Basic"
        }
    }
}

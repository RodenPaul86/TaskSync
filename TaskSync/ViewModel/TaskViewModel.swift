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
    @Published var taskColor: String = "Black"
    @Published var TeskDeadline: Date = Date()
    @Published var taskType: String = "Basic"
}

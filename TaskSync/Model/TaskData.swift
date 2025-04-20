//
//  Task.swift
//  TaskSync
//
//  Created by Paul  on 3/30/25.
//

import SwiftUI
import SwiftData

enum TaskPriority: String, Codable, CaseIterable {
    case none = "None"
    case basic = "Basic"
    case important = "Important"
    case urgent = "Urgent"
}

@Model /// <-- SwiftData Model
class TaskData: Identifiable {
    var id: UUID?
    var taskTitle: String = ""
    var taskDescription: String = ""
    var creationDate: Date = Date.now
    var isCompleted: Bool = false
    var tint: String = "taskColor 0"
    var priority: TaskPriority?
    
    init(id: UUID = .init(), taskTitle: String, taskDescription: String, creationDate: Date = .init(), isCompleted: Bool = false, tint: String, priority: TaskPriority = .basic) {
        self.id = id
        self.taskTitle = taskTitle
        self.taskDescription = taskDescription
        self.creationDate = creationDate
        self.isCompleted = isCompleted
        self.tint = tint
        self.priority = priority
    }
    
    var tintColor: Color {
        switch tint {
        case "taskColor 0": return .taskColor0
        case "taskColor 1": return .taskColor1
        case "taskColor 2": return .taskColor2
        case "taskColor 3": return .taskColor3
        case "taskColor 4": return .taskColor4
        case "taskColor 5": return .taskColor5
        case "taskColor 6": return .taskColor6
        default: return .black
        }
    }
}

extension Date {
    static func updateHour(_ value: Int) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .hour, value: value, to: .init()) ?? .init()
    }
}

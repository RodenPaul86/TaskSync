//
//  DynamicFilteredView.swift
//  TaskSync
//
//  Created by Paul  on 11/8/24.
//

import SwiftUI
import CoreData

enum TaskSortCriteria: String, CaseIterable, Hashable {
    case title = "Title"
    case priority = "Priority"
    case dueDate = "Due Date"
    case titleAndDueDate = "Title & Due Date"
    case priorityAndDueDate = "Priority & Due Date"
}

struct DynamicFilteredView<Content: View, T>: View where T: NSManagedObject {
    @FetchRequest var request: FetchedResults<T>
    private var content: (T) -> Content
    
    init(dateToFilter: Date, sortCriteria: TaskSortCriteria, @ViewBuilder content: @escaping (T) -> Content) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: dateToFilter)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        let filterKey = "taskDate"
        let predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@", argumentArray: [today, tomorrow])
        
        var sortDescriptors: [NSSortDescriptor] = []
        
        switch sortCriteria {
        case .priority:
            sortDescriptors = [NSSortDescriptor(keyPath: \Task.taskPriority, ascending: false)]
        case .dueDate:
            sortDescriptors = [NSSortDescriptor(keyPath: \Task.taskDate, ascending: true)]
        case .title:
            sortDescriptors = [NSSortDescriptor(keyPath: \Task.taskTitle, ascending: true)]
        case .titleAndDueDate:
            sortDescriptors = [
                NSSortDescriptor(keyPath: \Task.taskTitle, ascending: true),
                NSSortDescriptor(keyPath: \Task.taskDate, ascending: true)
            ]
        case .priorityAndDueDate:
            sortDescriptors = [
                NSSortDescriptor(keyPath: \Task.taskPriority, ascending: false),
                NSSortDescriptor(keyPath: \Task.taskDate, ascending: true)
            ]
        }
        
        _request = FetchRequest(entity: T.entity(), sortDescriptors: sortDescriptors, predicate: predicate)
        self.content = content
    }
    
    var body: some View {
        Group {
            if request.isEmpty {
                Text("No tasks available")
                    .foregroundColor(.gray)
                    .italic()
            } else {
                LazyVStack(spacing: 20) {
                    ForEach(request, id: \.objectID) { object in
                        content(object)
                    }
                }
            }
        }
    }
    
    // Function to return the dynamic task message
    private func getTaskMessage(for date: Date) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let targetDate = calendar.startOfDay(for: date)
        
        if targetDate == today {
            return "No tasks today"
        } else if targetDate == calendar.date(byAdding: .day, value: -1, to: today) {
            return "No tasks yesterday"
        } else if targetDate == calendar.date(byAdding: .day, value: 1, to: today) {
            return "No tasks tomorrow"
        } else {
            return "No tasks"
        }
    }
}

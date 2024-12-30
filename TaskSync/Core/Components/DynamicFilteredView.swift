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
    case priorityAndDueDate = "Priority & Due Date"
}

struct DynamicFilteredView<Content: View, T>: View where T: NSManagedObject {
    // MARK: CoreData Request
    @FetchRequest var request: FetchedResults<T>
    private var content: (T) -> Content
    private var dateToFilter: Date
    private var sortCriteria: TaskSortCriteria
    
    // MARK: Building Custom ForEach which will give CoreData object to build view
    init(dateToFilter: Date, sortCriteria: TaskSortCriteria, @ViewBuilder content: @escaping (T) -> Content) {
        self.dateToFilter = dateToFilter
        self.sortCriteria = sortCriteria
        
        // Build the predicate for filtering
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: dateToFilter)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        let filterKey = "taskDate"
        let predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@", argumentArray: [today, tomorrow, yesterday])
        
        // Sort based on the selected sort criteria
        let sortDescriptor: NSSortDescriptor
        switch sortCriteria {
        case .priority:
            sortDescriptor = NSSortDescriptor(keyPath: \Task.taskPriority, ascending: false)
        case .dueDate:
            sortDescriptor = NSSortDescriptor(keyPath: \Task.taskDate, ascending: true)
        case .title:
            sortDescriptor = NSSortDescriptor(keyPath: \Task.taskTitle, ascending: true)
        case .priorityAndDueDate:
            let primarySort = NSSortDescriptor(keyPath: \Task.taskPriority, ascending: false)
            let secondarySort = NSSortDescriptor(keyPath: \Task.taskDate, ascending: true)
            _request = FetchRequest(entity: T.entity(), sortDescriptors: [primarySort, secondarySort], predicate: predicate)
            self.content = content
            self.dateToFilter = dateToFilter
            return
        }
        
        // Initializing FetchRequest
        _request = FetchRequest(entity: T.entity(), sortDescriptors: [sortDescriptor], predicate: predicate)
        self.content = content
    }
    
    var body: some View {
        Group {
            if request.isEmpty {
                Text(getTaskMessage(for: dateToFilter))
                    .foregroundColor(.gray)
                    .italic()
                    .font(.title3)
                    .padding()
            } else {
                ForEach(request, id: \.objectID) { object in
                    self.content(object)
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

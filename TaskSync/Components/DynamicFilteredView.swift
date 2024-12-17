//
//  DynamicFilteredView.swift
//  TaskSync
//
//  Created by Paul  on 11/8/24.
//

import SwiftUI
import CoreData

struct DynamicFilteredView<Content: View, T>: View where T: NSManagedObject {
    // MARK: CoreData Request
    @FetchRequest var request: FetchedResults<T>
    let content: (T) -> Content
    let dateToFilter: Date
    
    // MARK: Building Custom ForEach which will give CoreData object to build view
    init(dateToFilter: Date, @ViewBuilder content: @escaping (T) -> Content) {
        // MARK: Predicate to filter tasks for today
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: dateToFilter)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        // Filter Key
        let filterKey = "taskDate"
        
        // Fetch tasks between today and tomorrow (24-hour window)
        let predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@", argumentArray: [today, tomorrow, yesterday])
        
        // Initializing Request with NSPredicate
        // Adding Sort
        _request = FetchRequest(entity: T.entity(), sortDescriptors: [.init(keyPath: \Task.taskDate, ascending: true)], predicate: predicate)
        self.content = content
        self.dateToFilter = dateToFilter
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

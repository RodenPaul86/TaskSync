//
//  DynamicFilteredView.swift
//  TaskSync
//
//  Created by Paul  on 11/8/24.
//

import SwiftUI
import CoreData

struct DynamicFilteredView<Content: View, T>: View where T: NSManagedObject {
    // MARK: Core Data Request
    @FetchRequest var request: FetchedResults<T>
    let content: (T) -> Content
    let isCurrentDay: Bool
    
    // MARK: Building Custom ForEach which will give CoreData object to build view
    
    init(dateToFilter: Date, isCurrentDay: Bool, @ViewBuilder content: @escaping (T) -> Content) {
        self.isCurrentDay = isCurrentDay
        
        // MARK: Predicate to filter current date task
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: dateToFilter)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        // Filter Key
        let filterKey = "taskDate"
        
        // Filtering for the current day tasks
        let predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@", argumentArray: [today, tomorrow])
        
        // Initializing Request With NSPredicate and adding sort
        _request = FetchRequest(entity: T.entity(), sortDescriptors: [
            NSSortDescriptor(keyPath: \Task.pinned, ascending: false), // Sort pinned tasks first
            NSSortDescriptor(keyPath: \Task.taskDate, ascending: true)
        ], predicate: predicate)
        
        self.content = content
    }
    
    var body: some View {
        Group {
            if request.isEmpty {
                Text("No tasks today")
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
}

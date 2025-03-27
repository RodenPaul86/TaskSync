//
//  DynamicFilteredView.swift
//  TaskSync
//
//  Created by Paul  on 3/11/25.
//

import SwiftUI
import CoreData

struct DynamicFilteredView<Content: View, T>: View where T: NSManagedObject {
    @FetchRequest var request: FetchedResults<T>
    let content: (T) -> Content
    
    init(currentTab: String, @ViewBuilder content: @escaping (T) -> Content) {
        let calendar = Calendar.current
        var predicate: NSPredicate?
        
        if currentTab == "Today" {
            let today = calendar.startOfDay(for: Date())
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
            
            let filterKey = "deadline"
            predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@ AND isCompleted == %i", argumentArray: [today, tomorrow, 0])
            
        } else if currentTab == "Upcoming" {
            let today = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date())!)
            let future = Date.distantFuture
            
            let filterKey = "deadline"
            predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@ AND isCompleted == %i", argumentArray: [today, future, 0])
            
        } else if currentTab == "Expired" {
            let today = calendar.startOfDay(for: Date())
            let past = Date.distantPast
            
            let filterKey = "deadline"
            predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@ AND isCompleted == %i", argumentArray: [past, today, 0])
            
        } else if currentTab == "Complete" {
            predicate = NSPredicate(format: "isCompleted == %i", argumentArray: [1])
            
        } else if currentTab == "All Tasks" {
            predicate = nil /// <-- No filtering, show everything!
        } else {
            // Fallback (optional)
            predicate = NSPredicate(value: true)
        }
        
        _request = FetchRequest(entity: T.entity(),
                                sortDescriptors: [.init(keyPath: \Task.deadline, ascending: true)],
                                predicate: predicate)
        
        self.content = content
    }
    
    var body: some View {
        Group {
            if request.isEmpty {
                Text("No Task Found!!!")
                    .font(.system(size: 16))
                    .fontWeight(.light)
                    .offset(y: 100)
            } else {
                ForEach(request, id: \.objectID) { object in
                    self.content(object)
                }
            }
        }
    }
}

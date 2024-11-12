//
//  DynamicFilteredView.swift
//  TaskSync
//
//  Created by Paul  on 11/8/24.
//

import SwiftUI
import CoreData

struct DynamicFilteredView<Content: View,T>: View where T: NSManagedObject {
    // MARK: Core Data Request
    @FetchRequest var request: FetchedResults<T>
    let content: (T)->Content
    
    // MARK: Building Custom ForEach which will give CoreData object to build view
    
    init(dateToFilter: Date,@ViewBuilder content: @escaping (T)->Content) {
        // MARK: Predicate to filter current date task
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: dateToFilter)
        let tommorow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        // Filter Key
        let filterkey = "taskDate"
        
        // This will fetch task between today and tommorow which is 24 hours
        let predicate = NSPredicate(format: "\(filterkey) >= %@ AND \(filterkey) =< %@", argumentArray: [today,tommorow])
        
        // Intializing Request With NSPredicate and adding sort
        _request = FetchRequest(entity: T.entity(), sortDescriptors: [.init(keyPath: \Task.taskDate, ascending: true)], predicate: predicate)
        self.content = content
    }
    
    var body: some View {
        Group {
            if request.isEmpty {
                Text("No tasks found!!!")
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

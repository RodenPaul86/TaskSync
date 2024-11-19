//
//  DynamicFilteredView.swift
//  TaskSync
//
//  Created by Paul  on 11/8/24.
//

import SwiftUI
import CoreData

struct DynamicFilteredView<Content: View,T>: View where T: NSManagedObject {
    // MARK: CoreData Request
    @FetchRequest var request: FetchedResults<T>
    let content: (T) -> Content
    
    // MARK: Building Custom ForEach whitch will give CoreData object to build view
    init(dateToFilter: Date, @ViewBuilder content: @escaping (T) -> Content) {
        
        // MARK: Predicate to filter current date Task
        let calendar = Calendar.current
        
        let today = calendar.startOfDay(for: dateToFilter)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        // Filter Key
        let filterKey = "taskDate"
        
        // This will fetch task between today and tomarrow whitch is 24 hours
        let predicate = NSPredicate(format: "\(filterKey) >= %@ AND \(filterKey) < %@", argumentArray: [today, tomorrow])
        
        // Intializing Request with NSPredicate
        // Adding Sort
        _request = FetchRequest(entity: T.entity(), sortDescriptors: [.init(keyPath: \Task.taskDate, ascending: false)], predicate: predicate)
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

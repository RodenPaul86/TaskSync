//
//  DynamicFilteredView.swift
//  TaskSync
//
//  Created by Paul  on 3/11/25.
//

import SwiftUI
import CoreData

struct DynamicFilteredView<Content: View, T: NSManagedObject>: View {
    @FetchRequest var request: FetchedResults<T>
    let content: (T) -> Content
    
    init(currentTab: String, sortKey: String, ascending: Bool = true, @ViewBuilder content: @escaping (T) -> Content) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var predicate: NSPredicate?
        
        switch currentTab {
        case "Today":
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) {
                predicate = NSPredicate(format: "%K >= %@ AND %K < %@ AND isCompleted == NO", sortKey, today as CVarArg, sortKey, tomorrow as CVarArg)
            }
        case "Upcoming":
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) {
                predicate = NSPredicate(format: "%K >= %@ AND isCompleted == NO", sortKey, tomorrow as CVarArg)
            }
        case "Expired":
            predicate = NSPredicate(format: "%K < %@ AND isCompleted == NO", sortKey, today as CVarArg)
        case "Complete":
            predicate = NSPredicate(format: "isCompleted == YES")
        case "All Tasks":
            predicate = nil /// <-- Show everything
        default:
            predicate = NSPredicate(value: true)
        }
        
        _request = FetchRequest(entity: T.entity(),
                                sortDescriptors: [NSSortDescriptor(key: sortKey, ascending: ascending)],
                                predicate: predicate)
        
        self.content = content
    }
    
    var body: some View {
        Group {
            if request.isEmpty {
                Text("No Tasks Found!!!")
                    .font(.callout)
                    .foregroundColor(.gray)
                    .padding(.top, 20)
            } else {
                VStack(alignment: .leading) {
                    ForEach(request, id: \.objectID) { object in
                        content(object)
                    }
                }
            }
        }
    }
}

//
//  TasksView.swift
//  TaskSync
//
//  Created by Paul  on 4/2/25.
//

import SwiftUI
import SwiftData

struct TasksView: View {
    @Binding var currentDate: Date
    
    @Query private var tasks: [TaskData]
    
    init(currentDate: Binding<Date>) {
        self._currentDate = currentDate
        
        /// Predicate
        let calendar = Calendar.current
        let startOfDate = calendar.startOfDay(for: currentDate.wrappedValue)
        let endOfDate = calendar.date(byAdding: .day, value: 1, to: startOfDate)!
        let predicate = #Predicate<TaskData> {
            return $0.creationDate >= startOfDate && $0.creationDate < endOfDate
        }
        /// Sorting
        let sortDescriptor = [
            SortDescriptor(\TaskData.creationDate, order: .forward)
        ]
        
        self._tasks = Query(filter: predicate, sort: sortDescriptor, animation: .snappy)
    }
    
    var body: some View {
        if tasks.isEmpty {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.seal")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                
                Text("You're all caught up!")
                    .font(.title3.bold())
                
                Text("Add a new task to get started or enjoy the calm while it lasts.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding()
            .foregroundStyle(.secondary.opacity(0.5))
            
        } else {
            VStack(alignment: .leading, spacing: 35) {
                ForEach(tasks) { task in
                    TaskRowView(task: task)
                        .background(alignment: .leading) {
                            if tasks.last?.id != task.id {
                                Rectangle()
                                    .frame(width: 1)
                                    .offset(x: 8)
                                    .padding(.bottom, -35)
                            }
                        }
                }
            }
            .padding([.vertical, .leading], 15)
            .padding(.top, 15)
        }
    }
}

#Preview {
    ContentView()
}

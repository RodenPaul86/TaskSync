//
//  DesignView.swift
//  TaskSync
//
//  Created by Paul  on 3/26/25.
//

import SwiftUI

struct TaskManagerView: View {
    @State private var activeTab: TabModel = .today
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom Tab Bar
                CustomTabBar(activeTab: $activeTab)
                
                // Task List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(getTasks(for: activeTab), id: \.self) { taskItem in
                            TaskRowView(task: taskItem)
                        }
                    }
                    .padding()
                }
                
                // Floating Add Task Button
                Button(action: addTask) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .frame(width: 56, height: 56)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding()
                .position(x: UIScreen.main.bounds.width - 50, y: UIScreen.main.bounds.height - 150)
            }
            .navigationTitle("Tasks")
        }
    }
    
    func getTasks(for tab: TabModel) -> [TaskItem] {
        // Placeholder function to return mock tasks
        return [
            TaskItem(title: "Buy groceries", deadline: "Today"),
            TaskItem(title: "Finish report", deadline: "Upcoming")
        ]
    }
    
    func addTask() {
        // Action to add a new task
    }
}

struct TaskRowView: View {
    let task: TaskItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.headline)
                Text(task.deadline)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct TaskItem: Identifiable, Hashable {
    let id = UUID() // Unique identifier
    let title: String
    let deadline: String
}

struct TaskManagerView_Previews: PreviewProvider {
    static var previews: some View {
        TaskManagerView()
    }
}

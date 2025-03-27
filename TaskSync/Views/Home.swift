//
//  Home.swift
//  TaskSync
//
//  Created by Paul  on 3/8/25.
//

import SwiftUI

struct Home: View {
    // MARK: Environment
    @Environment(\.self) var environment
    
    @StateObject var taskModel: TaskViewModel = .init()
    @Namespace var animation
    
    // MARK: Fetching Task
    @FetchRequest(
        entity: Task.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.deadline, ascending: false)],
        predicate: NSPredicate(format: "deadline >= %@ AND deadline < %@ AND isCompleted == NO",
                               Calendar.current.startOfDay(for: Date()) as NSDate,
                               Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))! as NSDate), animation: .easeInOut
    ) var todayTasks: FetchedResults<Task>
    
    @State private var activeTab: TabModel = .today
    
    // MARK: Main View
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            Section {
                VStack {
                    TaskView(currentTab: activeTab)
                }
                .padding(.horizontal)
                
            } header: {
                HeaderView()
            }
        }
        .overlay(alignment: .bottom) {
            // MARK: ADD Button
            Button {
                taskModel.openEditTask.toggle()
            } label: {
                Label {
                    Text("Add Task")
                        .font(.callout)
                        .fontWeight(.semibold)
                } icon: {
                    Image(systemName: "plus.app.fill")
                }
                .foregroundStyle(.white)
                .padding(.vertical, 12)
                .padding(.horizontal)
                .background {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(activeTab.color) // Use the tab's color dynamically
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background {
                LinearGradient(colors: [
                    .white.opacity(0.05),
                    .white.opacity(0.4),
                    .white.opacity(0.7),
                    .white
                ], startPoint: .top, endPoint: .bottom)
            }
        }
        .fullScreenCover(isPresented: $taskModel.openEditTask) {
            taskModel.resetTaskData()
        } content: {
            AddNewTask()
                .environmentObject(taskModel)
        }
    }
    
    // MARK: TaskView
    func TaskView(currentTab: TabModel) -> some View {
        LazyVStack(spacing: 20) {
            // MARK: Custom filtering request view
            DynamicFilteredView(currentTab: currentTab.rawValue) { (task: Task) in
                TaskRowView(task: task)
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: Task Row View
    @ViewBuilder
    func TaskRowView(task: Task) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(task.type ?? "")
                    .font(.callout)
                    .padding(.vertical, 5)
                    .padding(.horizontal)
                    .background {
                        Capsule()
                            .fill(.white.opacity(0.3))
                    }
                
                Spacer()
                
                // MARK: Edit button only for none completed tasks
                if !task.isCompleted && taskModel.currentTab != "Failed" {
                    Button(action: {
                        taskModel.editTask = task
                        taskModel.openEditTask = true
                        taskModel.setupTask()
                    }) {
                        Image(systemName: "square.and.pencil")
                            .font(.title2)
                            .foregroundStyle(.black)
                    }
                }
            }
            
            Text(task.title ?? "")
                .font(.title2.bold())
                .foregroundStyle(.black)
                .padding(.vertical, 10)
            
            HStack(alignment: .bottom, spacing: 0) {
                VStack(alignment: .leading, spacing: 10) {
                    Label {
                        Text((task.deadline ?? Date()).formatted(date: .long, time: .omitted))
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    .font(.caption)
                    
                    Label {
                        Text((task.deadline ?? Date()).formatted(date: .omitted, time: .shortened))
                    } icon: {
                        Image(systemName: "clock")
                    }
                    .font(.caption)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if !task.isCompleted && taskModel.currentTab != "Failed" {
                    Button(action: {
                        // MARK: Updating CoreData
                        task.isCompleted.toggle()
                        try? environment.managedObjectContext.save()
                    }) {
                        Circle()
                            .strokeBorder(.black, lineWidth: 1.5)
                            .frame(width: 25, height: 25)
                            .contentShape(Circle())
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(task.color ?? "Yellow"))
        }
    }
    
    // MARK: Header View
    func HeaderView() -> some View {
        VStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(Date().formatted(.dateTime.month())) \(Date().formatted(.dateTime.day())), \(Date().formatted(.dateTime.year()))")
                    .font(.callout.bold())
                    .foregroundStyle(.gray)
                
                Text("Today")
                    .font(.largeTitle.bold())
                
                Text("You have \(todayTasks.count) task\(todayTasks.count == 1 ? "" : "s") today")
                    .font(.title3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            
            // MARK: Custom Segmented Bar
            VStack(spacing: 0) {
                CustomTabBar(activeTab: $activeTab)
            }
        }
    }
}

struct CustomTabBar: View {
    @Binding var activeTab: TabModel
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
        GeometryReader { _ in
            HStack(spacing: 8) {
                HStack(spacing: activeTab == .allTask ? -15 : 8) {
                    ForEach(TabModel.allCases.filter({ $0 != .allTask }), id:\.rawValue) { tab in
                        ResizableTabButton(tab)
                    }
                }
                
                if activeTab == .allTask {
                    ResizableTabButton(.allTask)
                        .transition(.offset(x: 200))
                }
            }
            .padding(.horizontal, 15)
        }
        .frame(height: 50)
    }
    
    @ViewBuilder
    func ResizableTabButton(_ tab: TabModel) -> some View {
        HStack(spacing: 8) {
            Image(systemName: tab.symbolImage)
                .opacity(activeTab != tab ? 1 : 0)
                .overlay {
                    Image(systemName: tab.symbolImage)
                        .symbolVariant(.fill)
                        .opacity(activeTab == tab ? 1 : 0)
                }
            
            if activeTab == tab {
                Text(tab.rawValue)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .lineLimit(1)
            }
        }
        .foregroundStyle(tab == .allTask ? schemeColor : activeTab == tab ? .white : .gray)
        .frame(maxHeight: .infinity)
        .frame(maxWidth: activeTab == tab ? .infinity : nil)
        .padding(.horizontal, activeTab == tab ? 10 : 20)
        .background {
            Rectangle()
                .fill(activeTab == tab ? tab.color : Color.gray.opacity(0.2))
        }
        .clipShape(.rect(cornerRadius: 20, style: .continuous))
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.background)
                .padding(activeTab == .allTask && tab != .allTask ? -3 : 3)
        }
        .contentShape(.rect)
        .onTapGesture {
            guard tab != .allTask else { return }
            withAnimation(.bouncy) {
                if activeTab == tab {
                    activeTab = .allTask
                } else {
                    activeTab = tab
                }
            }
        }
    }
    
    var schemeColor: Color {
        scheme == .dark ? .black : .white
    }
}


#Preview {
    Home()
}

//
//  Home.swift
//  TaskSync
//
//  Created by Paul on 11/3/24.
//

import SwiftUI
import CoreData

struct Home: View {
    @StateObject var taskModel: TaskViewModel = TaskViewModel()
    @Namespace var animation
    
    @Environment(\.managedObjectContext) var context
    
    @State private var selectedDate: Date = Date() // Default to today
    @State private var showActionSheet = false
    
    // MARK: Main View
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 15, pinnedViews: [.sectionHeaders]) {
                Section {
                    TasksView()
                } header: {
                    HeaderView()
                }
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .safeAreaPadding(.bottom, 60)
        .onAppear {
            taskModel.autoDeleteOldTasks(context: context)
        }
    }
    
    // MARK: Task View
    func TasksView() -> some View {
        LazyVStack(spacing: 20) {
            DynamicFilteredView(dateToFilter: taskModel.currentDay) { (task: Task) in
                TaskCardView(task: task)
            }
        }
        .padding()
    }
    
    // MARK: Task Card View
    func TaskCardView(task: Task) -> some View {
        HStack(alignment: .top, spacing: 30) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            task.isCompleted ? .green :
                                task.isCanceled ? .red :
                                (taskModel.isCurrentHour(date: task.taskDate ?? Date()) ? .black :
                                    (task.taskDate ?? Date()).compare(Date()) == .orderedAscending ? .gray : .clear)
                        )
                        .frame(width: 15, height: 15)
                        .background(Circle().stroke(.black, lineWidth: 3).padding(-3))
                        .scaleEffect(taskModel.isCurrentHour(date: task.taskDate ?? Date()) ? 0.8 : 1)
                    
                    if task.isCanceled {
                        Text("X")
                            .foregroundColor(.black)
                            .font(.system(size: 10, weight: .bold))
                    }
                    
                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.black)
                            .font(.system(size: 10, weight: .bold))
                    }
                }
                
                Rectangle().fill(.black).frame(width: 3)
            }
            
            VStack {
                HStack(alignment: .top, spacing: 15) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(task.taskTitle ?? "")
                            .font(.title3.bold())
                            .lineLimit(1)
                        
                        Text(task.taskDescription ?? "")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                    }
                    .hLeading()
                    
                    VStack(alignment: .trailing) {
                        Text(task.taskDate?.formatted(date: .omitted, time: .shortened) ?? "No date")
                            .font(.callout)
                        
                        if taskModel.isCurrentHour(date: task.taskDate ?? Date()) {
                            HStack {
                                Text("\(task.selectedHour) hr")
                                Text("\(task.selectedMinute) min")
                            }
                            .font(.caption)
                            .padding(.vertical, 10)
                        } else {
                            if task.taskPriority == "Urgent" {
                                HStack {
                                    if let priority = task.taskPriority {
                                        Image(systemName: icon(for: priority))
                                    }
                                    Text("\(task.taskPriority ?? "No Priority")")
                                        .fontWeight(.bold)
                                }
                                .font(.caption)
                                .foregroundColor(.black)
                                .padding(10)
                                .background(GeometryReader { geometry in
                                    Capsule(style: .circular)
                                        .strokeBorder(.gray, lineWidth: 1)
                                        .padding(2)
                                        .frame(width: geometry.size.width, height: geometry.size.height)
                                })
                            }
                        }
                    }
                }
                
                if taskModel.isCurrentHour(date: task.taskDate ?? Date()) {
                    HStack {
                        HStack {
                            if let priority = task.taskPriority {
                                Image(systemName: icon(for: priority))
                                    .foregroundColor(task.isCompleted ? .gray : .white)
                            }
                            Text(task.isCompleted ? "Completed" : "\(task.taskPriority ?? "No Priority")")
                                .fontWeight(.bold)
                                .foregroundColor(task.isCompleted ? .gray : .white)
                        }
                        .font(.footnote)
                        .padding(10)
                        .background(GeometryReader { geometry in
                            Capsule(style: .circular)
                                .strokeBorder(.white, lineWidth: 1)
                                .padding(2)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                        })
                        .hLeading()
                        
                        if !task.isCanceled && !task.isCompleted {
                            Button {
                                task.isCompleted = true
                                DispatchQueue.main.async {
                                    try? context.save()
                                }
                            } label: {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.black)
                                    .padding(10)
                                    .background(Color.white, in: Circle())
                            }
                        }
                    }
                    .padding(.top)
                }
            }
            .foregroundStyle(taskModel.isCurrentHour(date: task.taskDate ?? Date()) ? .white : .black)
            .padding(taskModel.isCurrentHour(date: task.taskDate ?? Date()) ? 15 : 15)
            .padding(.bottom, taskModel.isCurrentHour(date: task.taskDate ?? Date()) ? 0 : 10)
            .hLeading()
            .background(
                Color(.black)
                    .cornerRadius(25)
                    .opacity(taskModel.isCurrentHour(date: task.taskDate ?? Date()) ? 1 : 0)
            )
            .contextMenu {
                VStack {
                    if !task.isCanceled {
                        if task.taskDate?.compare(Date()) == .orderedDescending || Calendar.current.isDateInToday(task.taskDate ?? Date()) {
                            
                            Button {
                                taskModel.editTask = task
                                taskModel.addNewTask.toggle()
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }
                        
                        if taskModel.isCurrentHour(date: task.taskDate ?? Date()) {
                            if !task.isCompleted {
                                Button {
                                    task.isCompleted = true
                                    task.isCanceled = false
                                    DispatchQueue.main.async {
                                        try? context.save()
                                    }
                                } label: {
                                    Label("Complete", systemImage: "checkmark.circle")
                                }
                                
                                Button {
                                    if let notificationID = task.notificationID, task.hasNotification {
                                        NotificationManager.shared.cancelNotification(withIdentifier: notificationID)
                                        print("Notification canceled for task: \(task.taskTitle ?? "")")
                                    }
                                    
                                    task.isCanceled = true
                                    task.isCompleted = false
                                    
                                    DispatchQueue.main.async {
                                        try? context.save()
                                        print("Task marked as canceled and notification removed.")
                                    }
                                } label: {
                                    Label("Cancel", systemImage: "x.circle")
                                }
                            }
                        }
                    }
                    
                    Button(role: .destructive) {
                        showActionSheet.toggle()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .sheet(isPresented: $taskModel.addNewTask) {
                taskModel.editTask = nil
            } content: {
                NewTaskView()
                    .environmentObject(taskModel)
            }
            .confirmationDialog("", isPresented: $showActionSheet, titleVisibility: .hidden) {
                Button(role: .destructive) {
                    if task.hasNotification && ((task.notificationID?.isEmpty) == nil) {
                        NotificationManager.shared.cancelNotification(withIdentifier: task.notificationID ?? "")
                        task.hasNotification = false
                    }
                    
                    context.delete(task)
                    DispatchQueue.main.async {
                        try? context.save()
                    }
                } label: {
                    Text("Delete Task")
                }
            }
        }
        .hLeading()
    }
    
    // MARK: Header View
    func HeaderView() -> some View {
        VStack {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(Date().formatted(date: .abbreviated, time: .omitted))
                        .foregroundStyle(.gray)
                    Text(getDynamicDateTitle(for: selectedDate))
                        .font(.largeTitle.bold())
                }
                .hLeading()
            }
            
            // MARK: Horizontal Calendar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 7) {
                    ForEach(taskModel.currentWeek, id: \.self) { day in
                        VStack(spacing: 10) {
                            Text(taskModel.extractDate(date: day, format: "dd"))
                                .font(.system(size: 14))
                                .fontWeight(.semibold)
                            
                            Text(taskModel.extractDate(date: day, format: "EEE"))
                                .font(.system(size: 14))
                                .fontWeight(.semibold)
                            
                            Circle()
                                .fill(.white)
                                .frame(width: 8, height: 8)
                                .opacity(taskModel.isToday(date: day) ? 1 : 0)
                        }
                        .foregroundStyle(taskModel.isToday(date: day) ? .primary : .secondary)
                        .foregroundStyle(taskModel.isToday(date: day) ? .white : .black)
                        .frame(width: 45, height: 90)
                        .background(
                            ZStack {
                                if taskModel.isToday(date: day) {
                                    Capsule()
                                        .fill(Color.black.gradient)
                                        .matchedGeometryEffect(id: "CURRENTDAY", in: animation)
                                }
                            }
                        )
                        .contentShape(Capsule())
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                selectedDate = day
                                taskModel.currentDay = day
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .padding(.top, getSafeArea().top)
        .background(Color.white)
    }
}

extension Home {
    // Function to return dynamic date title
    private func getDynamicDateTitle(for date: Date) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date()) // Start of today
        let targetDate = calendar.startOfDay(for: date) // Start of the selected date
        
        if targetDate == today {
            return "Today"
        } else if targetDate == calendar.date(byAdding: .day, value: 1, to: today) {
            return "Tomorrow"
        } else if targetDate == calendar.date(byAdding: .day, value: -1, to: today) {
            return "Yesterday"
        } else {
            // Format the date for the day after tomorrow or any other day
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d" // Example: Dec 18
            return formatter.string(from: date)
        }
    }
    
    // MARK: icons for priority
    func icon(for priority: String) -> String {
        switch priority {
        case "Urgent":
            return "flame.fill"
        case "Normal":
            return "hourglass"
        case "Low":
            return "leaf.fill"
        default:
            return "circle"
        }
    }
}

// MARK: Extension
extension View {
    func hLeading() -> some View {
        self.frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func hTrailing() -> some View {
        self.frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    func hCenter() -> some View {
        self.frame(maxWidth: .infinity, alignment: .center)
    }
    
    func getSafeArea() -> UIEdgeInsets {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return .zero }
        
        guard let safeArea = screen.windows.first?.safeAreaInsets else {
            return .zero
        }
        return safeArea
    }
}

#Preview {
    Home()
}

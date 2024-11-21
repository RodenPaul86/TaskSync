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
    
    func TasksView() -> some View {
        LazyVStack(spacing: 20) {
            DynamicFilteredView(dateToFilter: taskModel.currentDay) { (object: Task) in
                TaskCardView(task: object)
            }
        }
        .padding()
    }
    
    func TaskCardView(task: Task) -> some View {
        HStack(alignment: .top, spacing: 30) {
            // Side circle indecator and vertical line
            VStack(spacing: 10) {
                Circle()
                    .fill(
                        taskModel.isCurrentHour(date: task.taskDate ?? Date()) ?
                        (task.isCompleted ? .green : .black) :  // Current task: green if completed, red if not completed
                        (task.taskDate ?? Date()).compare(Date()) == .orderedAscending ? // Past task (before now)
                        (task.isCompleted ? .green : .red) : // Past tasks: green if completed, red if not completed
                            .clear // Future tasks are clear
                    )
                    .frame(width: 15, height: 15)
                    .background(
                        Circle()
                            .stroke(.black, lineWidth: 3)
                            .padding(-3)
                    )
                    .scaleEffect(taskModel.isCurrentHour(date: task.taskDate ?? Date()) ? 0.8 : 1)
                
                Rectangle()
                    .fill(.black)
                    .frame(width: 3)
            }
            
            // Task Card
            VStack {
                HStack(alignment: .top, spacing: 15) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(task.taskTitle ?? "")
                            .font(.title2.bold())
                            .lineLimit(1)
                        
                        Text(task.taskDescription ?? "")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                        
                    }
                    .hLeading()
                    
                    VStack(alignment: .trailing) {
                        HStack {
                            Image(systemName: "bell")
                                .foregroundStyle(.white)
                                .opacity(taskModel.isCurrentHour(date: task.taskDate ?? Date()) ? 1 : 0)
                            
                            Text(task.taskDate?.formatted(date: .omitted, time: .shortened) ?? "No date")
                                .font(.callout)
                        }
                        
                        HStack {
                            Text("\(task.selectedHour) h")
                                .opacity(taskModel.isCurrentHour(date: task.taskDate ?? Date()) ? 1 : 0)
                                .padding(.vertical, 10)
                            
                            Text("\(task.selectedMinute) m")
                                .opacity(taskModel.isCurrentHour(date: task.taskDate ?? Date()) ? 1 : 0)
                                .padding(.vertical, 10)
                        }
                    }
                }
                
                if taskModel.isCurrentHour(date: task.taskDate ?? Date()) {
                    HStack {
                        Text(task.isCompleted ? "Completed" : "\(task.taskPriority ?? "No Priority")")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(task.isCompleted ? .gray : .white) // Text color
                            .padding(10)
                            .background(GeometryReader { geometry in
                                Capsule(style: .circular)
                                    .strokeBorder(.white, lineWidth: 1)
                                    .padding(2)
                                    .frame(width: geometry.size.width, height: geometry.size.height)
                            })
                            .hLeading()
                        
                        if !task.isCompleted {
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
                    if task.taskDate?.compare(Date()) == .orderedDescending || Calendar.current.isDateInToday(task.taskDate ?? Date()) {
                        
                        Button {
                            taskModel.editTask = task
                            taskModel.addNewTask.toggle()
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                    }
                    Button(role: .destructive) {
                        context.delete(task)
                        DispatchQueue.main.async {
                            try? context.save()
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            } // Adding ContextMenu for Haptic Touch
            .sheet(isPresented: $taskModel.addNewTask) {
                taskModel.editTask = nil
            } content: {
                NewTaskView()
                    .environmentObject(taskModel)
            }
        }
        .hLeading()
    }
    
    func HeaderView() -> some View {
        VStack {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 10) {
                    // Display today's date
                    Text(Date().formatted(date: .abbreviated, time: .omitted))
                        .foregroundStyle(.gray)
                    
                    // Display "Today" title
                    Text("Today")
                        .font(.largeTitle.bold())
                }
                .hLeading()
            }
            
            // Horizontal Calendar
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
                            withAnimation(.easeInOut) { // Simplified animation
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

extension View {
    func hLeading() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func hTrailing() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    func hCenter() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .center)
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

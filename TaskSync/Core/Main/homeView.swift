//
//  Home.swift
//  TaskSync
//
//  Created by Paul on 11/3/24.
//

import SwiftUI
import CoreData

struct homeView: View {
    @Environment(\.managedObjectContext) var context
    @StateObject var taskModel: TaskViewModel = TaskViewModel() // Observing TaskViewModel
    
    @AppStorage("startOfWeek") private var startOfWeek: String = "Sunday" // Observing user preference
    @AppStorage("sortOption") private var sortOption: String = "Due Date"
    
    @Namespace var animation
    @State private var selectedDate: Date = Date() // Default to today
    
    @State private var currentDate = Date()
    @State private var isTodayUpdated = false
    @State private var timer: Timer?
    
    @State private var sortCriteria: TaskSortCriteria = .dueDate
    
    @State private var showSheet: Bool = false
    @State private var showDeleteComfirm = false
    @State private var showActionComfirm = false
    
    private let dateToFilter = Date() // Today's date
    
    
    // MARK: Main View
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 15, pinnedViews: [.sectionHeaders]) {
                Section {
                    VStack {
                        LazyVStack(spacing: 20) {
                            DynamicFilteredView(dateToFilter: dateToFilter, sortCriteria: sortCriteria) { (task: Task) in
                                TaskCardView(task: task)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: sortOption) { oldValue, newValue in
                        // Update the sortCriteria when sortOption changes
                        sortCriteria = TaskSortCriteria(rawValue: newValue) ?? .priorityAndDueDate
                    }
                } header: {
                    HeaderView()
                }
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .safeAreaPadding(.bottom, 60)
        .onAppear {
            DispatchQueue.main.async {
                taskModel.autoDeleteOldTasks(context: context)
                taskModel.startSyncing()
            }
        }
    }
    
    // MARK: Task Card View
    func TaskCardView(task: Task) -> some View {
        // Get current hour
        let currentHour = Calendar.current.component(.hour, from: Date())
        
        // Check if the task's due hour matches the current hour and update the task
        if let taskDueDate = task.taskDate {
            let taskHour = Calendar.current.component(.hour, from: taskDueDate)
            
            // If the task's due hour matches the current hour
            if taskHour == currentHour && !task.isCompleted && !task.isCanceled {
                // Perform the update asynchronously to avoid modifying state during view update
                DispatchQueue.main.async {
                    // Animate the status change
                    withAnimation(.easeInOut(duration: 0.3)) {
                        // Update the task's status or other properties as needed
                        task.status = "Ready for action"  // You can customize this status or logic as needed
                    }
                    
                    // Save the context asynchronously to avoid blocking the UI
                    do {
                        try context.save()
                    } catch {
                        print("Failed to save task: \(error)")
                    }
                }
            }
        }
        
        var isCurrentHour: Bool {
            taskModel.isCurrentHour(date: task.taskDate ?? Date())
        }
        
        return HStack(alignment: .top, spacing: 30) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            task.isCompleted ? .green :
                                task.isCanceled ? .red :
                                (isCurrentHour ? .black :
                                    (task.taskDate ?? Date()).compare(Date()) == .orderedAscending ? .gray : .clear)
                        )
                        .frame(width: 15, height: 15)
                        .background(Circle().stroke(.black, lineWidth: 3).padding(-3))
                        .scaleEffect(isCurrentHour ? 0.8 : 1)
                    
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
                VStack(alignment: .leading) { // <-- This is the beginning of task card.
                    HStack(alignment: .top) { // <-- Task Header
                        VStack(alignment: .leading) {
                            HStack {
                                Text(task.taskDate?.formatted(date: .omitted, time: .shortened) ?? "No date")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                
                                if isCurrentHour {
                                    Text("(\(task.selectedHour) hr, \(task.selectedMinute) min)")
                                        .font(.footnote)
                                        .foregroundStyle(.gray)
                                }
                            }
                            
                            Text(task.taskTitle ?? "")
                                .font(.title2.bold())
                                .foregroundStyle(task.isCrossedOut ? .gray : taskModel.isCurrentHour(date: task.taskDate ?? Date()) ? .white : .black)
                                .strikethrough(task.isCrossedOut, color: .black)
                                .animation(.easeInOut, value: task.isCrossedOut)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        if isCurrentHour || task.taskPriority == "Urgent" {
                            Image(systemName: icon(for: task.taskPriority ?? ""))
                                .foregroundStyle(task.isCompleted ? .gray : isCurrentHour ? .white : .black)
                                .font(.footnote)
                                .padding(10)
                                
                        }
                    }
                    
                    Text(task.taskDescription ?? "")
                        .font(.callout)
                        .foregroundStyle(.gray)
                        .padding(.vertical, 2)
                        .lineLimit(3)
                }
                .hLeading()
                
                if isCurrentHour {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            showActionComfirm.toggle()
                        }, label: {
                            Image(systemName: "ellipsis")
                                .foregroundStyle(.black)
                                .frame(width: 42, height: 42)
                                .background(Color.white, in: Circle())
                        })
                    }
                    .confirmationDialog("What would you like to do?", isPresented: $showActionComfirm, titleVisibility: .visible) {
                        // Real actions
                        if !task.isCompleted {
                            Button("Complete") {
                                task.isCrossedOut.toggle()
                                task.isCompleted = true
                                DispatchQueue.main.async {
                                    try? context.save()
                                }
                            }
                        }
                        
                        Button("Edit Task") {
                            taskModel.editTask = task
                            taskModel.addNewTask.toggle()
                        }
                        
                        Button("Delete", role: .destructive) {
                            showDeleteComfirm.toggle()
                        }
                        
                        Button("Cancel", role: .cancel) {}
                    }
                }
            }
            .padding(isCurrentHour ? 15 : 15)
            .padding(.bottom, isCurrentHour ? 0 : 10)
            .hLeading()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isCurrentHour ? .black : Color.clear)
                    .overlay(
                        isCurrentHour ? nil : Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(.gray), alignment: .top
                    )
            )
            .contextMenu {
                VStack {
                    if !task.isCanceled {
                        if task.taskDate?.compare(Date()) == .orderedDescending || Calendar.current.isDateInToday(task.taskDate ?? Date()) {
                            
                            Button {
                                taskModel.editTask = task
                                taskModel.addNewTask.toggle()
                            } label: {
                                Label("Edit", systemImage: "square.and.pencil")
                            }
                        }
                        
                        if isCurrentHour {
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
                        showDeleteComfirm.toggle()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .sheet(isPresented: $taskModel.addNewTask) {
                taskModel.editTask = nil
            } content: {
                newTaskView()
                    .environmentObject(taskModel)
            }
            .confirmationDialog("Are you sure you want to delete this task?", isPresented: $showDeleteComfirm, titleVisibility: .visible) {
                Button(role: .destructive) {
                    deleteTask(task)
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
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 10) {
                    Text(getDynamicDateTitle(for: selectedDate))
                        .font(.largeTitle.bold())
                    
                    if Calendar.current.isDate(selectedDate, inSameDayAs: Date()) {
                        Text("\(Date().formatted(.dateTime.month())), \(Date().formatted(.dateTime.year()))")
                            .font(.title2.bold())
                            .foregroundStyle(.gray)
                            .baselineOffset(-10)
                    }
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
            .onAppear {
                taskModel.fetchCurrentWeek(startOfWeek: startOfWeek) // Fetch initial week
                checkIfDayChanged()
                startPeriodicCheck() // Start periodic check when the app is active
            }
            .onChange(of: startOfWeek) { oldStartOfWeek, newStartOfWeek in
                taskModel.fetchCurrentWeek(startOfWeek: newStartOfWeek) // React to setting changes
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                // Check if the day has changed when app comes into the foreground
                checkIfDayChanged()
                startPeriodicCheck() // Restart periodic check if needed
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                // Stop the timer when the app goes into the background
                stopPeriodicCheck()
            }
        }
        .padding()
        .padding(.top, getSafeArea().top)
        .background(Color.white)
    }
    
    private func checkIfDayChanged() {
        let newDate = Date()
        if !Calendar.current.isDate(newDate, inSameDayAs: currentDate) {
            withAnimation(.easeInOut) {
                currentDate = newDate
                isTodayUpdated.toggle() // Trigger view update
                taskModel.currentDay = newDate
            }
        }
    }
    
    private func startPeriodicCheck() {
        // Check every minute if the day has changed
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            checkIfDayChanged()
        }
    }
    
    private func stopPeriodicCheck() {
        // Invalidate the timer when app goes into the background
        timer?.invalidate()
        timer = nil
    }
    
    func deleteTask(_ task: Task) {
        guard let context = task.managedObjectContext else { return }
        
        let taskID = task.objectID // Get unique ID for the task
        
        DispatchQueue.main.async {
            do {
                // Fetch the object from Core Data using the objectID
                if let taskToDelete = try context.existingObject(with: taskID) as? Task {
                    context.delete(taskToDelete) // Safely delete the object
                    try context.save() // Save changes
                    print("Task deleted: \(taskToDelete.taskTitle ?? "Unknown")")
                }
            } catch {
                print("Error deleting task: \(error)")
            }
        }
    }
}

#Preview {
    homeView()
}

extension homeView {
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
            // Check if the date is in the next week (for better dynamic text)
            let components = calendar.dateComponents([.year, .month, .day], from: today)
            let targetComponents = calendar.dateComponents([.year, .month, .day], from: targetDate)
            
            // If the date is within the same year and month, format it more simply
            if components.year == targetComponents.year && components.month == targetComponents.month {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d" // Example: Dec 18
                return formatter.string(from: date)
            }
            
            // Default format for other dates
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy" // Example: Dec 18, 2024
            return formatter.string(from: date)
        }
    }
    
    // MARK: icons for priority
    func icon(for priority: String) -> String {
        switch priority {
        case "Urgent":
            return "flame.fill"
        case "Normal":
            return "tray"
        case "Low":
            return "leaf"
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

/// Sample View
struct SheetView: View {
    var title: String
    var content: String
    var image: Config
    var button1: Config
    var button2: Config?
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: image.content)
                .font(.title)
                .foregroundStyle(image.foreground)
                .frame(width: 65, height: 65)
                .background(image.tint.gradient, in: .circle)
            
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(.black)
            
            Text(content)
                .font(.callout)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .foregroundStyle(.gray)
            
            ButtonView(button1)
            
            if let button2 {
                ButtonView(button2)
            }
        }
    }
    
    @ViewBuilder
    func ButtonView(_ config: Config) -> some View {
        Text(config.content)
            .fontWeight(.semibold)
            .foregroundColor(config.foreground)
            .padding(.vertical, 10)
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(config.tint.gradient, in: .rect(cornerRadius: 10))
    }
    
    struct Config {
        var content: String
        var tint: Color
        var foreground: Color
    }
}

//
//  NewTaskView.swift
//  TaskSync
//
//  Created by Paul  on 3/31/25.
//

import SwiftUI

struct NewTaskView: View {
    // MARK: Paywall Properties
    @EnvironmentObject var appSubModel: appSubscriptionModel
    @State private var isPaywallPresented: Bool = false
    
    /// View Properties
    @Environment(\.dismiss) private var dismiss
    
    /// Model Context For Saving Data
    @Environment(\.modelContext) private var context
    
    /// Optional task for editing
    var taskToEdit: Task?
    
    @State private var taskTitle: String = ""
    @State private var taskDescription: String = ""
    @State private var taskDate: Date
    @State private var taskColor: String = "taskColor 0"
    
    @State private var taskPriority: TaskPriority = .none
    
    init(taskToEdit: Task? = nil, defaultDate: Date = .now) {
        self.taskToEdit = taskToEdit
        _taskDate = State(initialValue: taskToEdit?.creationDate ?? defaultDate)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(taskToEdit != nil ? "Edit Task" : "New Task")
                    .font(.title2.bold())
                    .padding(.bottom, 5)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .tint(Color(.lightGray))
                        .opacity(0.25)
                }
            }
            .hSpacing(.trailing)
            
            VStack(alignment: .leading, spacing: 8) {
                TextField("Title", text: $taskTitle)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 15)
                    .background(.ultraThinMaterial.shadow(.drop(color: .black.opacity(0.25), radius: 2)), in: .rect(cornerRadius: 10))
            }
            .padding(.top, 5)
            
            VStack(alignment: .leading, spacing: 8) {
                TextField("Description (Optional)", text: $taskDescription)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 15)
                    .background(.ultraThinMaterial.shadow(.drop(color: .black.opacity(0.25), radius: 2)), in: .rect(cornerRadius: 10))
            }
            .padding(.top, 5)
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Deadline")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    
                    DatePicker("", selection: $taskDate)
                        .datePickerStyle(.compact)
                        .scaleEffect(0.9, anchor: .leading)
                }
                .padding(.trailing, -15)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Color")
                        .font(.caption)
                        .foregroundStyle(.gray)
                    
                    let color: [String] = (0...6).compactMap { index -> String in
                        return "taskColor \(index)"
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(color.enumerated()), id: \.element) { index, color in
                                Circle()
                                    .fill(Color(color))
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Group {
                                            if !appSubModel.isSubscriptionActive && index != 0 {
                                                Image(systemName: "lock.fill")
                                                    .foregroundColor(.gray)
                                                    .font(.system(size: 10))
                                            }
                                        }
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(lineWidth: 2)
                                            .opacity(taskColor == color ? 1 : 0)
                                    )
                                    .contentShape(.rect)
                                    .onTapGesture {
                                        if appSubModel.isSubscriptionActive || index == 0 {
                                            withAnimation(.snappy) {
                                                taskColor = color
                                            }
                                        } else {
                                            // Optionally trigger your paywall here
                                            isPaywallPresented = true
                                        }
                                    }
                                    .fullScreenCover(isPresented: $isPaywallPresented) {
                                        SubscriptionView(isPaywallPresented: $isPaywallPresented)
                                            .preferredColorScheme(.dark)
                                    }
                            }
                        }
                        .padding([.vertical, .horizontal], 4)
                    }
                }
            }
            .padding(.top, 5)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Priority")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                Picker("Priority", selection: $taskPriority) {
                    ForEach(TaskPriority.allCases, id: \.self) { priority in
                        Text(priority.rawValue).tag(priority)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.top, 5)
            
            Spacer(minLength: 0)
            
            Button(action: {
                /// Saving Task
                if let task = taskToEdit {
                    task.taskTitle = taskTitle
                    task.taskDescription = taskDescription
                    task.creationDate = taskDate
                    task.tint = taskColor
                    task.priority = taskPriority
                    
                } else {
                    let task = Task(taskTitle: taskTitle, taskDescription: taskDescription, creationDate: taskDate, tint: taskColor, priority: taskPriority)
                    context.insert(task)
                }
                
                do {
                    try context.save()
                    dismiss()
                } catch {
                    print(error.localizedDescription)
                }
            }) {
                Text(taskToEdit != nil ? "Update Task" : "Create Task")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .textScale(.secondary)
                    .foregroundStyle(taskTitle.isEmpty ? .gray : .primary)
                    .hSpacing(.center)
                    .padding(.vertical, 12)
                    .background(Color(taskColor).gradient, in: .rect(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(taskTitle.isEmpty ? .gray : .white, lineWidth: 0.5)
                    }
            }
            .disabled(taskTitle.isEmpty)
            .opacity(taskTitle.isEmpty ? 0.5 : 1)
        }
        .padding(15)
        .onAppear {
            if let task = taskToEdit {
                taskTitle = task.taskTitle
                taskDescription = task.taskDescription
                taskDate = task.creationDate
                taskColor = task.tint
                taskPriority = task.priority ?? .none
            }
        }
    }
}

#Preview {
    NewTaskView()
        .vSpacing(.bottom)
}

//
//  NewTaskView.swift
//  TaskSync
//
//  Created by Paul  on 11/9/24.
//

import SwiftUI

struct NewTaskView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject var taskModel: TaskViewModel

    @State private var taskTitle: String = ""
    @State private var taskDescription: String = ""
    @State private var taskDate: Date = Date()
    
    @State private var taskEstTime: Int = 1
    @State private var taskPriority: String = "NORMAL"
    
    let priorities = ["URGENT", "NORMAL", "LOW"]

    var body: some View {
        VStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 15, pinnedViews: [.sectionHeaders]) {
                    Section(header: headerView()) {
                        formFields()
                            .onAppear(perform: loadTaskData)
                    }
                }
            }
            Spacer()
            saveButton()
        }
    }

    private func loadTaskData() {
        if let task = taskModel.editTask {
            taskTitle = task.taskTitle ?? ""
            taskDescription = task.taskDescription ?? ""
            taskDate = task.taskDate ?? Date()
            taskEstTime = Int(task.taskEstTime)
            taskPriority = task.taskPriority ?? "NORMAL"
        }
    }

    @ViewBuilder
    private func formFields() -> some View {
        VStack(alignment: .leading, spacing: 30) {
            InputField(title: "Title", text: $taskTitle, placeholder: "Event title")
            InputField(title: "Description", text: $taskDescription, placeholder: "Description (Optional)")
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Date")
                        .font(.callout)
                        .foregroundStyle(.gray)
                    DatePicker("", selection: $taskDate, displayedComponents: .date)
                        .labelsHidden()
                        .accentColor(.black)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Time")
                        .font(.callout)
                        .foregroundStyle(.gray)
                    DatePicker("", selection: $taskDate, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .accentColor(.black)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Estimate")
                        .font(.callout)
                        .foregroundColor(.gray)
                    
                    Picker("", selection: $taskEstTime) {
                        ForEach(0..<25) { hour in
                            Text("\(hour) hours").tag(hour)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .accentColor(.black)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                }
            }
            
            Text("Priority")
                .font(.callout)
                .foregroundColor(.gray)
            
            HStack(spacing: 10) {
                ForEach(priorities, id: \.self) { priorityLevel in
                    Button(action: {
                        taskPriority = priorityLevel
                    }) {
                        Text(priorityLevel)
                            .fontWeight(.bold)
                            .foregroundColor(taskPriority == priorityLevel ? .blue : .white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(taskPriority == priorityLevel ? Color.white : Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
            }
            .padding(10)
            .background(Color.blue.opacity(0.2))
            .cornerRadius(10)
        }
        .padding()
    }

    private func saveButton() -> some View {
        Button(action: saveTask) {
            Text(taskModel.editTask != nil ? "Update" : "Create")
                .font(.title2.bold())
                .foregroundColor(taskTitle.isEmpty ? .gray : .white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black.gradient)
                .cornerRadius(50)
        }
        .disabled(taskTitle.isEmpty)
        .padding(.horizontal)
        .padding(.bottom)
    }

    private func saveTask() {
        let task = taskModel.editTask ?? Task(context: context)
        task.taskTitle = taskTitle
        task.taskDescription = taskDescription
        task.taskDate = taskDate
        task.taskEstTime = Int16(taskEstTime)
        task.taskPriority = taskPriority
        try? context.save()
        dismiss()
    }

    private func headerView() -> some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 10) {
                dismissButton()
                
                Text(taskModel.editTask != nil ? "Edit Task" : "New Task")
                    .font(.largeTitle.bold())
            }
            .hLeading()
        }
        .padding()
        .background(Color.white)
    }

    private func dismissButton() -> some View {
        Button(action: { dismiss() }) {
            Image(systemName: "xmark")
                .frame(width: 10, height: 10)
                .foregroundColor(.white)
                .padding()
                .background(Color.black.gradient)
                .clipShape(Circle())
                
        }
    }
}

struct InputField: View {
    var title: String
    @Binding var text: String
    var placeholder: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.callout)
                .foregroundStyle(.gray)
            
            TextField(placeholder, text: $text)
                .clearButton(text: $text)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .font(.system(size: 16))
        }
    }
}

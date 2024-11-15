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
        }
    }

    @ViewBuilder
    private func formFields() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            InputField(title: "Title", text: $taskTitle, placeholder: "Event title")
            InputField(title: "Description", text: $taskDescription, placeholder: "Description (Optional)")
            VStack(alignment: .leading, spacing: 8) {
                Text("Date and Time")
                    .font(.caption)
                    .foregroundStyle(.gray)
                DatePicker("", selection: $taskDate)
                    .labelsHidden()
            }
        }
        .padding()
    }

    private func saveButton() -> some View {
        Button(action: saveTask) {
            Label(taskModel.editTask != nil ? "Update" : "Create", systemImage: "")
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
                .font(.caption)
                .foregroundStyle(.gray)
            
            TextField(placeholder, text: $text)
                .clearButton(text: $text)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .font(.system(size: 16))
        }
    }
}

//
//  AddNewTask.swift
//  TaskSync
//
//  Created by Paul  on 3/10/25.
//

import SwiftUI

struct AddNewTask: View {
    @EnvironmentObject var taskModel: TaskViewModel
    @Environment(\.self) var environment
    @Namespace var animation
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Edit Task")
                .font(.title3.bold())
                .frame(maxWidth: .infinity)
                .overlay(alignment: .leading) {
                    Button(action: {
                        environment.dismiss()
                    }){
                        Image(systemName: "arrow.left")
                            .font(.title3)
                            .foregroundStyle(.black)
                    }
                }
                .overlay(alignment: .trailing) {
                    Button(action: {
                        if let editTask = taskModel.editTask {
                            environment.managedObjectContext.delete(editTask)
                            try? environment.managedObjectContext.save()
                            environment.dismiss()
                        }
                    }){
                        Image(systemName: "trash")
                            .font(.title3)
                            .foregroundStyle(.red)
                    }
                    .opacity(taskModel.editTask == nil ? 0 : 1)
                }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Task Color")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                // MARK: Sample Card Colors
                let color: [String] = ["Gray", "Yellow", "Green", "Blue", "Purple", "Red", "Orange"]
                
                HStack(spacing: 15) {
                    ForEach(color, id: \.self) { color in
                        Circle()
                            .fill(Color(color))
                            .frame(width: 25, height: 25)
                            .background {
                                if taskModel.taskColor == color {
                                    Circle()
                                        .strokeBorder(.gray)
                                        .padding(-3)
                                }
                            }
                            .contentShape(Circle())
                            .onTapGesture {
                                taskModel.taskColor = color
                            }
                    }
                }
                .padding(.top, 10)
            }
            .frame(maxWidth:.infinity, alignment: .leading)
            .padding(.top, 30)
            
            Divider()
                .padding(.vertical, 10)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Task Deadline")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                Text(taskModel.taskDeadline.formatted(date: .abbreviated, time: .omitted) + ", " + taskModel.taskDeadline.formatted(date: .omitted, time: .shortened))
                    .font(.callout)
                    .fontWeight(.semibold)
                    .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .bottomTrailing) {
                Button(action: {
                    taskModel.showDatePicker.toggle()
                }) {
                    Image(systemName: "calendar")
                        .foregroundStyle(.black)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Task Title")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                // MARK: Sample Card TextField
                TextField("", text: $taskModel.taskTitle)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
            }
            .padding(.top, 10)
            
            Divider()
            
            // MARK: Sample Task Type
            let taskType: [String] = ["Basic", "Urgent", "Important"]
            VStack(alignment: .leading, spacing: 12) {
                Text("Task Type")
                    .font(.caption)
                    .foregroundStyle(.gray)
                
                HStack(spacing: 12) {
                    ForEach(taskType, id: \.self) { type in
                        Text(type)
                            .font(.callout)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(taskModel.taskType == type ? .white : .black)
                            .background {
                                if taskModel.taskType == type {
                                    Capsule()
                                        .fill(.black)
                                        .matchedGeometryEffect(id: "TYPE", in: animation)
                                } else {
                                    Capsule()
                                        .strokeBorder(.black)
                                }
                            }
                            .contentShape(Capsule())
                            .onTapGesture {
                                withAnimation { taskModel.taskType = type }
                            }
                    }
                }
                .padding(.top, 8)
            }
            .padding(.vertical, 10)
            
            Divider()
            
            // MARK: Save Button
            Button(action: {
                // MARK: If Success Closing View
                if taskModel.addTask(context: environment.managedObjectContext) {
                    environment.dismiss()
                }
            }) {
                Text("Save Task")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(.white)
                    .background {
                        Capsule()
                            .fill(.black)
                    }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 10)
            .disabled(taskModel.taskTitle == "")
            .opacity(taskModel.taskTitle == "" ? 0.6 : 1)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
        .overlay {
            ZStack {
                if taskModel.showDatePicker {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                        .onTapGesture {
                            taskModel.showDatePicker = false
                        }
                    
                    // MARK: Disabling Past Date
                    DatePicker.init("", selection: $taskModel.taskDeadline, in: Date.now...Date.distantFuture)
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .padding()
                        .background(.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .padding()
                }
            }
            .animation(.easeInOut, value: taskModel.showDatePicker)
        }
    }
}

#Preview {
    AddNewTask()
        .environmentObject(TaskViewModel())
}

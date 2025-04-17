//
//  TaskRowView.swift
//  TaskSync
//
//  Created by Paul  on 3/31/25.
//

import SwiftUI

struct TaskRowView: View {
    @Bindable var task: Task
    @Environment(\.modelContext) private var context /// <-- Model Context
    @State private var updateTask: Bool = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Circle()
                .fill(indicatorColor)
                .frame(width: 10, height: 10)
                .padding(4)
                .background(.white.shadow(.drop(color: .black.opacity(0.1), radius: 3)), in: Circle())
                .overlay {
                    Circle()
                        .foregroundStyle(.clear)
                        .contentShape(.circle)
                        .frame(width: 50, height: 50)
                        .onTapGesture {
                            withAnimation(.snappy) {
                                task.isCompleted.toggle()
                            }
                        }
                }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text(task.taskTitle)
                        .font(.title3.bold())
                        .foregroundStyle(task.isCompleted ? .gray : .primary)
                        .lineLimit(1)
                        .strikethrough(task.isCompleted, pattern: .solid, color: .primary)
                    
                    Spacer()
                    
                    Text(task.creationDate.format("hh:mm a"))
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
                
                HStack(alignment: .bottom) {
                    Text(task.taskDescription)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .textScale(.secondary)
                        .foregroundStyle(.gray)
                        .lineLimit(2)
                        .strikethrough(task.isCompleted, pattern: .solid, color: .primary)
                    
                    Spacer()
                    
                    if task.priority != TaskPriority.none {
                        Text(task.priority?.rawValue.capitalized ?? "")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(priorityColor(for: task.priority ?? .none))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(priorityColor(for: task.priority ?? .none).opacity(0.2), in: .capsule)
                    }
                }
            }
            .padding(15)
            .hSpacing(.leading)
            .background(task.tintColor, in: .rect(topLeadingRadius: 15, bottomLeadingRadius: 15))
            .contentShape(.contextMenuPreview, .rect(cornerRadius: 15))
            .contextMenu {
                Button(action: { updateTask.toggle() }) {
                    Label("Edit Task", systemImage: "square.and.pencil")
                }
                
                Button(action: { task.isCompleted.toggle() }) {
                    if !task.isCompleted {
                        Label("Mark as complete", systemImage: "checkmark.circle")
                    } else {
                        Label("Unmark as complete", systemImage: "xmark.circle")
                    }
                }
                
                Button(role: .destructive, action: {
                    context.delete(task)
                    try? context.save()
                }) {
                    Label("Delete", systemImage: "trash")
                }
            }
            .offset(y: -8)
            .sheet(isPresented: $updateTask) {
                NewTaskView(taskToEdit: task)
                    .presentationDetents([.height(400)])
                    .interactiveDismissDisabled()
                    .presentationCornerRadius(30)
                    .presentationBackground(.ultraThinMaterial)
            }
        }
    }
    
    var indicatorColor: Color {
        if task.isCompleted {
            return .green
        }
        
        return task.creationDate.isSameHour ? .blue : (task.creationDate.isPast ? .red : .black)
    }
    
    func priorityColor(for priority: TaskPriority) -> Color {
        switch priority {
        case .none: return .clear
        case .basic: return .blue
        case .important: return .orange
        case .urgent: return .red
        }
    }
}

#Preview {
    ContentView()
}

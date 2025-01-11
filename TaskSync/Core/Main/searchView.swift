//
//  SearchView.swift
//  TaskSync
//
//  Created by Paul  on 11/12/24.
//

import SwiftUI
import CoreData

struct searchView: View {
    @Binding var isSearching: Bool
    @Binding var filteredTasks: [Task]
    @Environment(\.managedObjectContext) var context
    
    @State private var searchText: String = ""
    
    var body: some View {
        VStack {
            Section {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(filteredTasks) { task in
                            CustomTaskView(task: task, onDelete: {
                                filterTasks() // Reload the task list and results count after deletion
                            })
                        }
                    }
                }
                .safeAreaPadding(.bottom, 60)
                .onAppear {
                    filterTasks() // Initial load to show data if needed
                }
            } header: {
                HeaderView()
            }
        }
    }
    
    func HeaderView() -> some View {
        VStack {
            // Search Bar
            HStack {
                TextField("Search tasks...", text: $searchText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .onChange(of: searchText) {
                        filterTasks()
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        filteredTasks = []
                        isSearching = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            
            // Display search status
            if isSearching {
                Text("\(filteredTasks.count) result(s) found")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.bottom, 5)
            }
        }
        .onChange(of: searchText) {
            isSearching = !searchText.isEmpty
        }
    }
    
    // MARK: Filter Tasks
    func filterTasks() {
        if searchText.isEmpty {
            filteredTasks = []
            isSearching = false
            return
        }
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "taskTitle CONTAINS[c] %@ OR taskDescription CONTAINS[c] %@", searchText, searchText)
        
        do {
            filteredTasks = try context.fetch(fetchRequest)
            isSearching = !filteredTasks.isEmpty
        } catch {
            print("Failed to fetch filtered tasks: \(error.localizedDescription)")
            filteredTasks = []
        }
    }
}

struct CustomTaskView: View {
    @Environment(\.managedObjectContext) var context
    
    @State private var showActionSheet: Bool = false
    
    var task: Task
    var onDelete: (() -> Void)?
    
    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(task.taskTitle ?? "")
                            .font(.title2.bold())
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text(task.taskDate?.formatted(date: .numeric, time: .omitted) ?? "")
                            
                            Text(task.taskDate?.formatted(date: .omitted, time: .shortened) ?? "")
                        }
                        .font(.callout)
                    }
                    
                    Text(task.taskDescription ?? "")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .hLeading()
            }
            
            HStack {
                Spacer()
                
                Button {
                    self.showActionSheet.toggle()
                } label: {
                    Image(systemName: "ellipsis")
                        .padding()
                        .frame(width: 42, height: 42)
                        .background(Color.white, in: Circle())
                        .foregroundColor(.black)
                }
                .actionSheet(isPresented: $showActionSheet) {
                    ActionSheet(
                        title: Text(""),
                        message: Text("This task will be deleted permanently. Do you want to proceed?"), buttons: [
                            .destructive(Text("Delete")) {
                                context.delete(task)
                                DispatchQueue.main.async {
                                    try? context.save()
                                    
                                    onDelete?()
                                }
                            },
                            .cancel()
                        ])
                }
            }
            
            /*
            if taskModel.isCurrentHour(date: task.taskDate ?? Date()) {
                HStack(spacing: 12) {
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
                    
                    Text(task.isCompleted ? "Completed" : "")
                        .font(.system(size: task.isCompleted ? 14 : 16, weight: .light))
                        .foregroundStyle(task.isCompleted ? .gray : .white)
                        .hLeading()
                    
                    Spacer()
                }
                .padding(.top)
            }
             */
        }
        .foregroundStyle(.white)
        .padding()
        .hLeading()
        .background(
            Color(.black)
                .cornerRadius(25)
        )
        .padding([.leading, .trailing])
    }
}

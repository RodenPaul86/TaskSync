//
//  SearchView.swift
//  TaskSync
//
//  Created by Paul  on 11/12/24.
//

import SwiftUI
import CoreData

struct SearchView: View {
    @Binding var isSearching: Bool
    @Binding var filteredTasks: [Task]
    @Environment(\.managedObjectContext) var context
    
    @State private var searchText: String = ""
    
    var body: some View {
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
        .onChange(of: searchText) { newValue in
            isSearching = !newValue.isEmpty
        }
    }
    
    // MARK: Filter Tasks
    private func filterTasks() {
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

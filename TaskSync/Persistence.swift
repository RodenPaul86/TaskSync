//
//  Persistence.swift
//  TaskSync
//
//  Created by Paul  on 11/3/24.
//

import CoreData
import UIKit

struct PersistenceController {
    static let shared = PersistenceController()
    
    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Example: Create preview data if needed
        /// for _ in 0..<10 {
        ///     let newItem = Task(context: viewContext)
        ///     newItem.title = "Sample Task"
        ///     newItem.dueDate = Date()
        /// }
        
        do {
            try viewContext.save()
        } catch {
            handleCoreDataError(error)
        }
        
        return result
    }()
    
    let container: NSPersistentCloudKitContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "TaskSync")
        
        // Configure persistent store
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            container.persistentStoreDescriptions.forEach { description in
                description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.studio4design.TaskSync")
            }
        }
        
        // Load the persistent store
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                PersistenceController.handleCoreDataError(error)
            } else {
                print("Successfully loaded persistent store: \(storeDescription)")
            }
        }
        
        // Configure viewContext properties
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy // Prioritize local changes
        container.viewContext.shouldDeleteInaccessibleFaults = true // Clean up broken references
    }
    
    // MARK: - Helper for Core Data Errors
    private static func handleCoreDataError(_ error: Error) {
        guard let nsError = error as NSError? else { return }
        print("Unresolved error: \(nsError), \(nsError.userInfo)")
        
        // Optionally show a global alert
        /*
        AlertHelper.showGlobalAlert(
            title: "Core Data Error",
            message: "An issue occurred while accessing the app's data. Please try again later or contact support."
        )
         */
    }
}

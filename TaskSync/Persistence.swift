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
        ///        for _ in 0..<10 {
        ///            let newItem = Item(context: viewContext)
        ///            newItem.timestamp = Date()
        ///        }
        do {
            try viewContext.save()
        } catch {
            if let error = error as NSError? {
                // Log the error for debugging purposes
                print("Unresolved error: \(error), \(error.userInfo)")
                
                AlertHelper.showGlobalAlert(title: "Error", message: "An issue occurred while accessing the app's data. Please try again later or contact support.")
            }
            //let nsError = error as NSError
            //fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    let container: NSPersistentCloudKitContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "TaskSync")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Log the error for debugging purposes
                print("Unresolved error: \(error), \(error.userInfo)")
                
                AlertHelper.showGlobalAlert(title: "Error", message: "An issue occurred while accessing the app's data. Please try again later or contact support.")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

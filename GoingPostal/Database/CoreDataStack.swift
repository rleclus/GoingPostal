//
//  CoreDataStack.swift
//  GoingPostal
//
//  Created by Robert le Clus on 2024/05/14.
//

import Foundation
import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PostModel")
        // Configure the persistent store description
        let description = NSPersistentStoreDescription()
        description.type = NSSQLiteStoreType // Specify SQLite as the persistent store type
        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.za.co.rleclus") {
            let storeURL = appGroupURL.appendingPathComponent("PostModel.sqlite")
            description.url = storeURL
        } else {
            fatalError("Unable to access App Group container URL")
        }
        // Set the persistent store descriptions
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    func backgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

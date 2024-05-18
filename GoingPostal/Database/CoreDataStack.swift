//
//  CoreDataStack.swift
//  GoingPostal
//
//  Created by Robert le Clus on 2024/05/14.
//

import Foundation
import CoreData

class CoreDataStack {
    var persistentContainer: NSPersistentContainer
    init(inMemory: Bool = false) {
        if inMemory {
            persistentContainer = PersistenceFactory.makeInMemoryPersistenceContainer()
        } else {
            persistentContainer = PersistenceFactory.makeSQLPersistenceContainer()
        }
    }
    
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

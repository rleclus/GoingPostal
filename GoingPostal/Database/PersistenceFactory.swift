//
//  PersistenceFactory.swift
//  GoingPostal
//
//  Created by Robert le Clus on 2024/05/18.
//

import Foundation
import CoreData

class PersistenceFactory {
    static func makeInMemoryPersistenceContainer() -> NSPersistentContainer {
        let persistenceContainer = NSPersistentContainer(name: "PostModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistenceContainer.persistentStoreDescriptions = [description]
        persistenceContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return persistenceContainer
    }

    static func makeSQLPersistenceContainer() -> NSPersistentContainer {
        let persistenceContainer = NSPersistentContainer(name: "PostModel")
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
        persistenceContainer.persistentStoreDescriptions = [description]
        persistenceContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return persistenceContainer
    }
}

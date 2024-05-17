//
//  Post+CoreDataProperties.swift
//  GoingPostal
//
//  Created by Robert le Clus on 2024/05/14.
//
//

import Foundation
import CoreData


extension Post {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Post> {
        return NSFetchRequest<Post>(entityName: "Post")
    }

    @NSManaged public var userID: Int32
    @NSManaged public var id: Int32
    @NSManaged public var title: String?
    @NSManaged public var body: String?

}

extension Post : Identifiable {

}

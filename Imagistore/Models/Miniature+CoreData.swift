//
//  Miniature+CoreDataProperties.swift
//  Imagistore
//
//  Created by Yevhen Hruzinov on 29.11.2023.
//
//

import Foundation
import CoreData

@objc(Miniature)
public class Miniature: NSManagedObject {

}

extension Miniature {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Miniature> {
        return NSFetchRequest<Miniature>(entityName: "Miniature")
    }

    @NSManaged public var uuid: UUID
    @NSManaged public var library: UUID?
    @NSManaged public var miniature: Data?

}

extension Miniature : Identifiable {

}

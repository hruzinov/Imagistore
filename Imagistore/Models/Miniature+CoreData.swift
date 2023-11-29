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
    @NSManaged public var miniature: Data?

}

extension Miniature : Identifiable {

}

func getMiniature(for uuid: UUID, context: NSManagedObjectContext) -> Data? {
    let fetchRequest: NSFetchRequest<Miniature>
    fetchRequest = Miniature.fetchRequest()
    fetchRequest.fetchLimit = 1

    fetchRequest.predicate = NSPredicate(
        format: "uuid == %@", uuid as CVarArg
    )
    let objects = try! context.fetch(fetchRequest)
    return objects.first?.miniature
}

//
//  Created by Evhen Gruzinov on 07.05.2023.
//

import Foundation
import CoreData

extension PhotosLibrary {

    public class func fetchRequest() -> NSFetchRequest<PhotosLibrary> {
        NSFetchRequest<PhotosLibrary>(entityName: "PhotosLibrary")
    }

    @NSManaged public var version: Int16
    @NSManaged public var uuid: UUID
    @NSManaged public var name: String?
    @NSManaged public var lastChange: Date
    @NSManaged public var photos: NSSet

}

extension PhotosLibrary: Identifiable {

}

// MARK: Generated accessors for photos
extension PhotosLibrary {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: Photo)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: Photo)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)

}

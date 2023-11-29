//
//  Created by Evhen Gruzinov on 07.05.2023.
//

import Foundation
import CoreData

@objc(PhotosLibrary)
public class PhotosLibrary: NSManagedObject {
    static var actualLibraryVersion = 1

    lazy var idPredicate = {
        NSPredicate(format: "uuid = %@", self.uuid as CVarArg)
    }()
}

extension PhotosLibrary {

    public class func fetchRequest() -> NSFetchRequest<PhotosLibrary> {
        NSFetchRequest<PhotosLibrary>(entityName: "PhotosLibrary")
    }

    @NSManaged public var version: Int16
    @NSManaged public var uuid: UUID
    @NSManaged public var name: String?
    @NSManaged public var lastChange: Date
    @NSManaged public var albums: [UUID]?
    @NSManaged public var photosIDs: [UUID]

}

extension PhotosLibrary: Identifiable {

}
//
//// MARK: Generated accessors for photos
//extension PhotosLibrary {
//
//    @objc(addPhotosObject:)
//    @NSManaged public func addToPhotos(_ value: Photo)
//
//    @objc(removePhotosObject:)
//    @NSManaged public func removeFromPhotos(_ value: Photo)
//
//    @objc(addPhotos:)
//    @NSManaged public func addToPhotos(_ values: NSSet)
//
//    @objc(removePhotos:)
//    @NSManaged public func removeFromPhotos(_ values: NSSet)
//
//}

// MARK: Generated accessors for albums
extension PhotosLibrary {

    @objc(addAlbumsObject:)
    @NSManaged public func addToAlbums(_ value: Album)

    @objc(removeAlbumsObject:)
    @NSManaged public func removeFromAlbums(_ value: Album)

    @objc(addAlbums:)
    @NSManaged public func addToAlbums(_ values: NSSet)

    @objc(removeAlbums:)
    @NSManaged public func removeFromAlbums(_ values: NSSet)

}


enum PhotosSortArgument: String {
    case importDateDesc, creationDateDesc
    case importDateAsc, creationDateAsc
}

enum RemovingDirection: String {
    case bin
    case recover
    case permanent
}

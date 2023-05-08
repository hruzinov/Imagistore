//
//  Created by Evhen Gruzinov on 08.05.2023.
//

import Foundation
import CoreData

extension PhotosLibrary {
//    func addImages(_ images: [Photo], competition: @escaping (Int, Error?) -> Void) {
////        photos = loadLibrary(id: id)!.photos
//        var count = 0
//        for item in images {
//            photos.append(item)
//            count += 1
//        }
//        let err = saveLibrary(lib: self)
//        competition(count, err)
//    }

    func toBin(_ images: [Photo], in context: NSManagedObjectContext, competition: @escaping (Error?) -> Void) {
        let request = Photo.fetchRequest()
        let photosIDs = images.map { $0.uuid }
        request.predicate = NSPredicate(format: "uuid IN %@", photosIDs as CVarArg)
        do {
            let photoResult = try context.fetch(request)
            for item in photoResult {
                item.status = PhotoStatus.deleted.rawValue
                item.deletionDate = Date()
            }
            try context.save()
        } catch {
            competition(error)
        }
        competition(nil)
    }
    func recoverImages(_ images: [Photo], in context: NSManagedObjectContext, competition: @escaping (Error?) -> Void) {
        let request = Photo.fetchRequest()
        let photosIDs = images.map { $0.uuid }
        request.predicate = NSPredicate(format: "uuid IN %@", photosIDs as CVarArg)
        do {
            let photoResult = try context.fetch(request)
            for item in photoResult {
                item.status = PhotoStatus.normal.rawValue
                item.deletionDate = nil
            }
            try context.save()
        } catch {
            competition(error)
        }
        competition(nil)
    }
}

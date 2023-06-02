//
//  Created by Evhen Gruzinov on 08.05.2023.
//

import SwiftUI
import CoreData
import CloudKit

func generateMiniatureData(_ uiImage: UIImage) -> Data? {
    let miniatureMaxSize: CGFloat = 320

    let size: CGSize
    if uiImage.size.width > uiImage.size.height {
        let coefficient = uiImage.size.width / miniatureMaxSize
        size = CGSize(width: miniatureMaxSize, height: uiImage.size.height / coefficient)
    } else {
        let coefficient = uiImage.size.height / miniatureMaxSize
        size = CGSize(width: uiImage.size.width / coefficient, height: miniatureMaxSize)
    }
    let renderer = UIGraphicsImageRenderer(size: size)
    let uiImageMini = renderer.image { (_) in
        uiImage.draw(in: CGRect(origin: .zero, size: size))
    }
    let data = uiImageMini.heic(compressionQuality: 0.1)
    return data
}

extension PhotosLibrary {
    func toBin(_ images: [Photo], in context: NSManagedObjectContext, competition: @escaping (Error?) -> Void) {
        do {
            for item in images {
                item.status = PhotoStatus.deleted.rawValue
                item.deletionDate = Date()
            }
            self.lastChange = Date()
            try context.save()
        } catch {
            competition(error)
        }
        competition(nil)
    }
    func recoverImages(_ images: [Photo], in context: NSManagedObjectContext, competition: @escaping (Error?) -> Void) {
        do {
            for item in images {
                item.status = PhotoStatus.normal.rawValue
                item.deletionDate = nil
            }
            self.lastChange = Date()
            try context.save()
        } catch {
            competition(error)
        }
        competition(nil)
    }
    func permanentRemove(_ images: [Photo], in context: NSManagedObjectContext, competition: @escaping (Error?) -> Void) {
        do {
            var cloudIDArr = [CKRecord.ID]()
            images.forEach { photo in
                context.delete(photo)
                removeImageFile(photo) { _, error in
                    if let error { competition(error) }
                }
                self.removeFromPhotos(photo)
                if let cloudID = photo.fullsizeCloudID {
                    cloudIDArr.append(CKRecord.ID(recordName: cloudID))
                }
            }
            cloudDatabase.modifyRecords(saving: [], deleting: cloudIDArr) { result in
                switch result {
                case .success((_, let deletedRecords)):
                    debugPrint(deletedRecords)
                case .failure(let error):
                    competition(error)
                }
            }
            self.lastChange = Date()
            try context.save()
        } catch {
            competition(error)
        }
        competition(nil)
    }
    func clearBin(in context: NSManagedObjectContext, competition: @escaping (Error?) -> Void) {
        let request = Photo.fetchRequest()
        let libPredicate = NSPredicate(format: "library = %@", self as CVarArg)
        let deletedPredicate = NSPredicate(format: "deletionDate < %@", DateTimeFunctions.deletionDate as CVarArg)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [libPredicate, deletedPredicate])

        do {
            let forDeletion = try context.fetch(request)
            if forDeletion.count > 0 {
                permanentRemove(forDeletion, in: context) { error in
                    competition(error)
                }
            } else {
               competition(nil)
            }
        } catch {
            competition(error)
        }
        competition(nil)
    }

    func deleteLibrary(in context: NSManagedObjectContext, competition: @escaping (Error?) -> Void) {
        let request = Photo.fetchRequest()
        request.predicate = NSPredicate(format: "library = %@", self as CVarArg)

        do {
            let forDeletion = try context.fetch(request)
            if forDeletion.count > 0 {
                permanentRemove(forDeletion, in: context) { error in
                    if let error {
                        debugPrint("Im on step 4, error here")
                    }
                    competition(error)
                }
            }
            removeFolder(self) { result, error in
                if let error {
                    competition(error)
                } else if result {
                    context.delete(self)
                    try context.save()
                    competition(nil)
                } else {
                    print("Some error with deleting folder")
                }
            }
        } catch {
            competition(error)
        }
    }
}

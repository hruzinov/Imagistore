//
//  Created by Evhen Gruzinov on 14.03.2023.
//

import SwiftUI
import RealmSwift

class PhotosLibrary: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var name: String = "library"
    @Persisted var photos = RealmSwift.List<Photo>()
}

extension PhotosLibrary {
    func addImages(_ imgs: RealmSwift.List<Photo>, competition: @escaping (Int, Error?) -> Void) {
        let realm = self.realm?.thaw()
        let thawed = self.thaw()
        var count = 0
        for item in imgs {
            if let thawed {
                do {
                    try realm?.write({
                        thawed.photos.append(item)
                        count += 1
                    })
                } catch {
                    competition(count, error)
                }
            }
        }
        competition(count, nil)
    }
    
    func toBin(_ imgs: [Photo], competition: @escaping (Error?) -> Void) {
        let realm = self.realm?.thaw()
        let thawed = self.thaw()
        for item in imgs {
            if let thawed, let realm, let photoIndex = photos.firstIndex(of: item) {
                do {
                    try realm.write({
                        thawed.photos[photoIndex].status = .deleted
                        thawed.photos[photoIndex].deletionDate = Date()
                    })
                } catch {
                    competition(error)
                }
            }
        }
        competition(nil)
    }
    func recoverImages(_ imgs: [Photo], competition: @escaping (Error?) -> Void) {
        let realm = self.realm?.thaw()
        let thawed = self.thaw()
        for item in imgs {
            if let thawed, let realm, let photoIndex = photos.firstIndex(of: item) {
                do {
                    try realm.write({
                        thawed.photos[photoIndex].status = .normal
                        thawed.photos[photoIndex].deletionDate = nil
                    })
                } catch {
                    competition(error)
                }
            }
        }
        competition(nil)
    }
    func permanentRemove(_ imgs: [Photo], competition: @escaping (Error?) -> Void) {
        let realm = self.realm?.thaw()
        for item in imgs {
            if let realm {
                let (completed, error) = removeImageFile(id: item.id, fileExtention: item.fileExtention)
                if completed {
                    do {
                        try realm.write({
                            let photo = realm.objects(Photo.self).where({
                                $0.id == item.id
                            })
                            realm.delete(photo)
                        })
                    } catch {
                        competition(error)
                    }
                } else {
                    competition(error)
                }
            }
        }
        competition(nil)
    }
    
    func clearBin(competition: @escaping (Error?) -> Void) {
        var forDeletion = [Photo]()
        for item in photos {
            if item.status == .deleted, let deletionDate = item.deletionDate, TimeFunctions.daysLeft(deletionDate) < 0 {
                forDeletion.append(item)
            }
        }
        permanentRemove(forDeletion) { error in
            competition(error)
        }
    }
}

enum PhotosSortArgument: String {
    case importDate, creationDate
}

enum RemovingDirection {
    case bin
    case recover
    case permanent
}

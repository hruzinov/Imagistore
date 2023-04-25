//
//  Created by Evhen Gruzinov on 14.03.2023.
//

import SwiftUI

class PhotosLibrariesCollection: Codable {
    var libraries: [UUID]
    
    init() {
        self.libraries = []
    }
}

class PhotosLibrary: Identifiable, Codable, ObservableObject {
    static var actualLibraryVersion = 1
    var id: UUID
    var name: String
    var libraryVersion: Int
    var lastChangeDate: Date
    var lastSyncDate: Date?
    var photos: [Photo]
    
    init(id: UUID, name: String, libraryVersion: Int = actualLibraryVersion, lastChangeDate: Date = Date(), photos: [Photo] = []) {
        self.id = id
        self.name = name
        self.libraryVersion = libraryVersion
        self.photos = photos
        self.lastChangeDate = lastChangeDate
    }
    
    
    func addImages(_ imgs: [Photo], competition: @escaping (Int, Error?) -> Void) {
        var count = 0
        for item in imgs {
            photos.append(item)
            count += 1
        }
        if let e = saveLibrary(lib: self) {
            competition(count, e)
        }
        OnlineFunctions.addPhotos(imgs, lib: self) { err in
            competition(count, err)
        }
    }
    
    func toBin(_ imgs: [Photo], competition: @escaping (Error?) -> Void) {
        for item in imgs {
            if let photoIndex = photos.firstIndex(of: item) {
                photos[photoIndex].status = .deleted
                photos[photoIndex].deletionDate = Date()
            }
        }
        self.objectWillChange.send()
        if let e = saveLibrary(lib: self) {
            competition(e)
        }
        OnlineFunctions.toBin(imgs, lib: self) { err in
            competition(err)
        }
    }
    func recoverImages(_ imgs: [Photo], competition: @escaping (Error?) -> Void) {
        for item in imgs {
            if let photoIndex = photos.firstIndex(of: item) {
                photos[photoIndex].status = .normal
                photos[photoIndex].deletionDate = nil
            }
        }
        self.objectWillChange.send()
        if let e = saveLibrary(lib: self) {
            competition(e)
        }
        OnlineFunctions.recoverImages(imgs, lib: self) { err in
            competition(err)
        }
    }
    func permanentRemove(_ imgs: [Photo], competition: @escaping (Error?) -> Void) {
        for item in imgs {
            if let photoIndex = photos.firstIndex(of: item) {
                let (completed, error) = removeImageFile(id: item.id, fileExtention: item.fileExtention)
                if completed {
                    photos.remove(at: photoIndex)
                } else {
                    competition(error)
                }
            }
        }
        self.objectWillChange.send()
        if let e = saveLibrary(lib: self) {
            competition(e)
        }
        OnlineFunctions.permanentRemove(imgs, lib: self) { err in
            competition(err)
        }
    }
    func clearBin(competition: @escaping (Error?) -> Void) {
        var forDeletion = [Photo]()
        for item in photos {
            if item.status == .deleted, let deletionDate = item.deletionDate, TimeFunctions.daysLeft(deletionDate) < 0 {
                forDeletion.append(item)
            }
        }
        if forDeletion.count > 0 {
            permanentRemove(forDeletion) { error in
                competition(error)
            }
        }
    }
    
    func sortedPhotos(by: PhotosSortArgument, filter: PhotoStatus) -> [Photo]{
        return self.photos
            .sorted(by: { ph1, ph2 in
                if filter == .deleted, let delDate1 = ph1.deletionDate, let delDate2 = ph2.deletionDate {
                    return delDate1 < delDate2
                } else {
                    switch by {
                    case .importDate:
                        return ph1.importDate < ph2.importDate
                    case .creationDate:
                        return ph1.creationDate < ph2.creationDate
                    }
                }
            })
            .filter({ ph in
                ph.status == filter
            })
    }
}

enum PhotosSortArgument: String {
    case importDate, creationDate
}

enum RemovingDirection: String {
    case bin
    case recover
    case permanent
}

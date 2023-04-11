//
//  Created by Evhen Gruzinov on 14.03.2023.
//

import Foundation

class PhotosLibrary: Codable, ObservableObject {
    var libraryVersion: Int
    var photos: [Photo]
    
    init(libraryVersion: Int, photos: [Photo]) {
        self.libraryVersion = libraryVersion
        self.photos = photos
    }
    
    func addImages(_ imgs: [Photo]) {
        for item in imgs {
            photos.append(item)
        }
        saveLibrary(lib: self)
    }
    
    func toBin(_ imgs: [Photo]) {
        for item in imgs {
            if let photoIndex = photos.firstIndex(of: item) {
                photos[photoIndex].status = .deleted
                photos[photoIndex].deletionDate = Date()
            }
        }
        self.objectWillChange.send()
        saveLibrary(lib: self)
    }
    func recoverImages(_ imgs: [Photo]) {
        for item in imgs {
            if let photoIndex = photos.firstIndex(of: item) {
                photos[photoIndex].status = .normal
                photos[photoIndex].deletionDate = nil
            }
        }
        self.objectWillChange.send()
        saveLibrary(lib: self)
    }
    func permanentRemove(_ imgs: [Photo]) {
        for item in imgs {
            if let photoIndex = photos.firstIndex(of: item) {
                if removeImageFile(id: item.id, fileExtention: item.fileExtention) {
                    photos.remove(at: photoIndex)
                }
            }
        }
        self.objectWillChange.send()
        saveLibrary(lib: self)
    }
    
    func filterPhotos(status: PhotoStatus) -> [Photo] {
        var newArray = [Photo]()
        for item in photos {
            if item.status == status {
                newArray.append(item)
            }
        }
        return newArray
    }
}

enum PhotosSortArgument {
    case importDate, creationDate
}

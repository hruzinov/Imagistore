//
//  Created by Evhen Gruzinov on 14.03.2023.
//

import Foundation

struct PhotosLibrary: Codable {
    var libraryVersion: Int
    var photos: [Photo]
    
    mutating func addImages(_ imgs: [Photo]) {
        for item in imgs {
            photos.append(item)
        }
        saveLibrary(lib: self)
    }
    
    mutating func toBin(_ imgs: [Photo]) {
        for item in imgs {
            if let photoIndex = photos.firstIndex(of: item) {
                photos[photoIndex].status = .deleted
                photos[photoIndex].deletionDate = Date()
            }
        }
        saveLibrary(lib: self)
    }
    mutating func recoverImages(_ imgs: [Photo]) {
        for item in imgs {
            if let photoIndex = photos.firstIndex(of: item) {
                photos[photoIndex].status = .normal
                photos[photoIndex].deletionDate = nil
            }
        }
        saveLibrary(lib: self)
    }
    mutating func permanentRemove(_ imgs: [Photo]) {
        for item in imgs {
            if let photoIndex = photos.firstIndex(of: item) {
                if removeImageFile(id: item.id, fileExtention: item.fileExtention) {
                    photos.remove(at: photoIndex)
                }
            }
        }
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

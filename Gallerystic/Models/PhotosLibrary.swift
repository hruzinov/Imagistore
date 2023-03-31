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
//            debugPrint(item)
        }
    }
    
    mutating func removeImages(_ imgs: [Photo]) {
        for item in imgs {
            if let photoIndex = photos.firstIndex(of: item) {
                photos[photoIndex].status = .deleted
            }
        }
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
    
    func withSortedPhotos(by: PhotosSortArgument) -> PhotosLibrary {
        var newPhotos = photos
        switch by {
        case .importDate:
            newPhotos.sort { p1, p2 in
                p1.importDate < p2.importDate
            }
        case .creationDate:
            newPhotos.sort { p1, p2 in
                p1.creationDate < p2.creationDate
            }
        }
        var sortedLibrary = self
        sortedLibrary.photos = newPhotos
        return sortedLibrary
    }
    
    enum PhotosSortArgument {
        case importDate, creationDate
    }
    
}

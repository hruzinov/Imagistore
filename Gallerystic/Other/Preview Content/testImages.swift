//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI

let testImages = [
    "testImage1",
    "testImage2",
    "testImage3",
    "testImage4",
    "testImage5",
]

var testImagesModels: [Photo] {
    var photoArr: [Photo] = []
    for item in testImages {
        let uuid = UUID()
        if UIImage(named: item) != nil {
            photoArr.append(Photo(id: uuid, status: .normal, creationDate: Date(), importDate: Date(), keywords: []))
        }
    }
    return photoArr
}

//var testLibrary: PhotosLibrary {
//    var lib: PhotosLibrary
//    
//    return lib
//}

func saveTestImagesToLibrary() {
    var photoArr: [Photo] = []
    for item in testImages {
        if let uiImage = UIImage(named: item) {
            let uuid = writeImageToFile(uiImage: uiImage)
            if let uuid {
                photoArr.append(Photo(id: uuid, status: .normal, creationDate: Date(), importDate: Date(), keywords: []))
            }
        }
    }
    saveLibrary(lib: PhotosLibrary(libraryVersion: 777, photos: photoArr))
}

//
//  Created by Evhen Gruzinov on 17.04.2023.
//

import SwiftUI

class UIImageHolder: ObservableObject {
    var data: [UUID: UIImage]
    private var fullsizeArr: [UUID]

    init() {
        data = [:]
        fullsizeArr = []
    }

    func fullUiImage(_ id: UUID) -> UIImage? {
        if fullsizeArr.contains(where: { $0 == id }), let uiImage = data[id] {
            return uiImage
        } else {
            return nil
        }
    }

    func getUiImage(_ photo: Photo, lib: PhotosLibrary) {
//        if let uiImage = data[photo.id] {
//        } else {
        readImageFromFile(photo.id, library: lib) { uiImage in
                if let uiImage {
                    self.data[photo.id] = uiImage
//                    DispatchQueue.main.async {
                        self.objectWillChange.send()
//                    }
                }
            }
//        }
    }
    func getFullUiImage(_ photo: Photo, lib: PhotosLibrary) {
//        if fullsizeArr.contains(where: { $0 == photo.id }), let uiImage = data[photo.id] {
////            completion(uiImage)
//        } else {
            readFullImageFromFile(photo.id, library: lib) { uiImage in
                if let uiImage {
                    self.data.updateValue(uiImage, forKey: photo.id)
                    self.fullsizeArr.append(photo.id)
//                    completion(uiImage)
//                    DispatchQueue.main.async {
                        self.objectWillChange.send()
//                    },
                }
            }
//        }
    }
}

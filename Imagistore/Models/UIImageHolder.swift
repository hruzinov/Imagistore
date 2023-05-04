//
//  Created by Evhen Gruzinov on 17.04.2023.
//

import SwiftUI

class UIImageHolder {
    var data: [UUID: UIImage]
    private var fullsizeArr: [UUID]

    init() {
        data = [:]
        fullsizeArr = []
    }

    func getUiImage(_ photo: Photo, lib: PhotosLibrary) -> UIImage? {
        if let uiImage = data[photo.id] {
            return uiImage
        } else {
            let uiImage = readImageFromFile(photo.id, library: lib)
            guard let uiImage else {
                return nil
            }
            data[photo.id] = uiImage
            return uiImage
        }
    }

    func getFullUiImage(_ photo: Photo, lib: PhotosLibrary) -> UIImage? {
        if fullsizeArr.contains(where: { $0 == photo.id }), let uiImage = data[photo.id] {
            return uiImage
        } else {
            let uiImage = readFullImageFromFile(photo.id, library: lib)
            guard let uiImage else {
                return nil
            }
            data.updateValue(uiImage, forKey: photo.id)
            fullsizeArr.append(photo.id)
            return uiImage
        }
    }
}

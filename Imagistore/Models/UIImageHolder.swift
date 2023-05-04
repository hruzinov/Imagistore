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

    func getUiImage(_ photo: Photo, lib: PhotosLibrary) async {
        await readImageFromFile(photo.id, library: lib) { uiImage in
                if let uiImage {
                    DispatchQueue.main.async {
                        self.data[photo.id] = uiImage
                        self.objectWillChange.send()
                    }
                }
            }
    }
    func getFullUiImage(_ photo: Photo, lib: PhotosLibrary) async {
        await readFullImageFromFile(photo.id, library: lib) { uiImage in
                if let uiImage {
                    DispatchQueue.main.async {
                        self.data.updateValue(uiImage, forKey: photo.id)
                        self.fullsizeArr.append(photo.id)
                        self.objectWillChange.send()
                    }
                }
            }
    }
}

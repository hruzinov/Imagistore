//
//  Created by Evhen Gruzinov on 17.04.2023.
//

import SwiftUI

class UIImageHolder: ObservableObject {
    var data: [UUID: UIImage]
    var notFound: [UUID]
    private var fullsizeArr: [UUID]

    init() {
        data = [:]
        fullsizeArr = []
        notFound = []
    }

    func fullUiImage(_ id: UUID) -> UIImage? {
        if fullsizeArr.contains(where: { $0 == id }), let uiImage = data[id] {
            return uiImage
        } else {
            return nil
        }
    }
    func getFullUiImage(_ photoID: UUID, lib: PhotosLibrary) async {
        await readImageFromFile(photoID, library: lib) { uiImage in
            if let uiImage {
                DispatchQueue.main.async {
                    self.data.updateValue(uiImage, forKey: photoID)
                    self.fullsizeArr.append(photoID)
                    self.objectWillChange.send()
                }
            }
        }
    }
}

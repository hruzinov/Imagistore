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
    func getFullUiImage(_ photo: Photo, completion: @escaping (Error?) -> Void) async {
        await readImageFromFile(photo) { uiImage, error in
            if let uiImage, let uuid = photo.uuid {
                DispatchQueue.main.async {
                    self.data.updateValue(uiImage, forKey: uuid)
                    self.fullsizeArr.append(uuid)
                    self.objectWillChange.send()
                }
            }
        }
    }
}

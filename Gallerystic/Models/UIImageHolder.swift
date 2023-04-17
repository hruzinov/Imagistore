//
//  Created by Evhen Gruzinov on 17.04.2023.
//

import SwiftUI

class UIImageHolder {
    var data: [UUID: UIImage]
    
    init() {
        self.data = [:]
    }
    
    func getUiImage(photo: Photo) -> UIImage? {
        if let uiImage = data[photo.id] {
            return uiImage
        } else {
            let uiImage = readImageFromFile(id: photo.id)
            guard let uiImage else {
                print("err")
                return nil
            }
            data.updateValue(uiImage, forKey: photo.id)
            return uiImage
        }
    }
}

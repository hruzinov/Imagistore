//
//  Created by Evhen Gruzinov on 14.03.2023.
//

import Foundation

struct PhotosLibrary: Codable {
    var photos: [Photo]
    
    mutating func addImages(_ imgs: [Photo]) {
        for item in imgs {
            photos.append(item)
        }
    }
}

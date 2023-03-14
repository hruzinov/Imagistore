//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI

struct Photo: Identifiable, Hashable, Codable {
    var id: UUID
    var status: PhotoStatus
    var creationDate: Date
    var keywords: [String]
}

enum PhotoStatus: Codable {
    case normal, deleted
}

//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI

struct Photo: Identifiable, Hashable, Codable {
    var id: UUID
    lazy var uiImage: UIImage? = readImageFromFile(id: id, fileExtention: fileExtention)
    var status: PhotoStatus
    var creationDate: Date
    var importDate: Date
    var deletionDate: Date?
    var fileExtention: PhotoExtention
    var keywords: [String]
}

enum PhotoStatus: Codable {
    case normal, deleted
}

enum PhotoExtention: String, Codable {
    case jpg
    case png
}

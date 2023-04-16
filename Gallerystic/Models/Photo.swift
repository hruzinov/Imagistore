//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI

class Photo: Identifiable, Codable {
    var id: UUID
    lazy var uiImage: UIImage? = readImageFromFile(id: id)
    var status: PhotoStatus
    var creationDate: Date
    var importDate: Date
    var deletionDate: Date?
    var fileExtention: PhotoExtention
    var keywords: [String]
    
    init(id: UUID, status: PhotoStatus, creationDate: Date, importDate: Date, deletionDate: Date? = nil, fileExtention: PhotoExtention, keywords: [String]) {
        self.id = id
        self.status = status
        self.creationDate = creationDate
        self.importDate = importDate
        self.deletionDate = deletionDate
        self.fileExtention = fileExtention
        self.keywords = keywords
    }
    
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        lhs.uiImage == rhs.uiImage
    }
}

extension Photo: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
}

enum PhotoStatus: Codable {
    case normal, deleted
}

enum PhotoExtention: String, Codable {
    case jpg
    case png
}

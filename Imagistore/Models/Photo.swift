//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI

class Photo: Identifiable, Codable, Equatable {
    var id: UUID
    var status: PhotoStatus
    var creationDate: Date
    var importDate: Date
    var deletionDate: Date?
    var fileExtension: PhotoExtension
    var keywords: [String]
    init(id: UUID, status: PhotoStatus, creationDate: Date, importDate: Date,
         deletionDate: Date? = nil, fileExtension: PhotoExtension, keywords: [String]) {
        self.id = id
        self.status = status
        self.creationDate = creationDate
        self.importDate = importDate
        self.deletionDate = deletionDate
        self.fileExtension = fileExtension
        self.keywords = keywords
    }
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        lhs.id == rhs.id
    }
}

enum PhotoStatus: String, Codable {
    case normal, deleted
}

enum PhotoExtension: String, Codable {
    case jpg
    case png
}

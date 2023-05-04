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


//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(id, forKey: .id)
//        try container.encode(status, forKey: .status)
//        try container.encode(creationDate, forKey: .creationDate)
//        try container.encode(importDate, forKey: .importDate)
//        try container.encode(deletionDate, forKey: .deletionDate)
//        try container.encode(fileExtension, forKey: .fileExtension)
//        try container.encode(keywords, forKey: .keywords)
//    }
//
//    required convenience init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        let id = try values.decode(UUID.self, forKey: .id)
//        let status = try values.decode(PhotoStatus.self, forKey: .status)
//        let creationDate = try values.decode(Date.self, forKey: .creationDate)
//        let importDate = try values.decode(Date.self, forKey: .importDate)
//        let deletionDate = try values.decode(Date?.self, forKey: .deletionDate)
//        let fileExtension = try values.decode(PhotoExtension.self, forKey: .fileExtension)
//        let keywords = try values.decode([String].self, forKey: .keywords)
//    }
//    enum CodingKeys: String, CodingKey {
//        case id
//        case status
//        case creationDate
//        case importDate
//        case deletionDate
//        case fileExtension
//        case keywords
//    }
}

//extension Photo: Codable {
//
//}

//extension Photo: Hashable {
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(self)
//    }
//}

enum PhotoStatus: String, Codable {
    case normal, deleted
}

enum PhotoExtension: String, Codable {
    case jpg
    case png
}

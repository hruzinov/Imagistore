//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI
import RealmSwift

class Photo: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: UUID = UUID()
    @Persisted var fileExtention: PhotoExtention
    @Persisted var status: PhotoStatus
    @Persisted var creationDate: Date
    @Persisted var importDate: Date
    @Persisted var deletionDate: Date?
    @Persisted var keywords: RealmSwift.List<String>
    
    private enum CodingKeys: String, CodingKey {
        case id
        case fileExtention
        case status
        case creationDate
        case importDate
        case deletionDate
        case keywords
    }
    
    convenience init(id: UUID, status: PhotoStatus, creationDate: Date, importDate: Date, deletionDate: Date? = nil, fileExtention: PhotoExtention, keywords: RealmSwift.List<String>) {
        self.init()
        self.id = id
        self.status = .normal
        self.creationDate = creationDate
        self.importDate = importDate
        self.deletionDate = deletionDate
        self.fileExtention = fileExtention
        self.keywords = keywords
    }
}

enum PhotoStatus: String, Codable, PersistableEnum {
    case normal
    case deleted
}

enum PhotoExtention: String, Codable, PersistableEnum {
    case jpg
    case png
}

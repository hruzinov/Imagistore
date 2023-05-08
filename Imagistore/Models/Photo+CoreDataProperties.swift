//
//  Created by Evhen Gruzinov on 07.05.2023.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var uuid: UUID?
    @NSManaged public var library: UUID
    @NSManaged public var status: String
    @NSManaged public var creationDate: Date
    @NSManaged public var importDate: Date
    @NSManaged public var deletionDate: Date?
    @NSManaged public var fileExtension: String?
    @NSManaged public var miniature: Data?

}

extension Photo : Identifiable {

}

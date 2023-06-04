//
//  Created by Evhen Gruzinov on 03.06.2023.
//

import Foundation
import CoreData


extension Album {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Album> {
        return NSFetchRequest<Album>(entityName: "Album")
    }

    @NSManaged public var uuid: UUID
    @NSManaged public var library: UUID
    @NSManaged public var photos: [UUID]
    @NSManaged public var title: String
    @NSManaged public var creationDate: Date

}

extension Album : Identifiable {

}

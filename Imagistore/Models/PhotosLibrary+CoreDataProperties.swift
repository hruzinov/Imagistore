//
//  Created by Evhen Gruzinov on 07.05.2023.
//

import Foundation
import CoreData

extension PhotosLibrary {

    public class func fetchRequest() -> NSFetchRequest<PhotosLibrary> {
        NSFetchRequest<PhotosLibrary>(entityName: "PhotosLibrary")
    }

    @NSManaged public var version: Int16
    @NSManaged public var id: UUID
    @NSManaged public var name: String?
    @NSManaged public var lastChange: Date
    @NSManaged public var photos: [UUID]

}

extension PhotosLibrary: Identifiable {

}

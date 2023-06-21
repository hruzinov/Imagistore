//
//  Created by Evhen Gruzinov on 03.06.2023.
//

import Foundation
import CoreData

@objc(Album)
public class Album: NSManagedObject {

}

extension Album {

    public class func fetchRequest() -> NSFetchRequest<Album> {
        NSFetchRequest<Album>(entityName: "Album")
    }

    @NSManaged public var uuid: UUID
    @NSManaged public var library: UUID
    @NSManaged public var photos: [UUID]
    @NSManaged public var title: String
    @NSManaged public var creationDate: Date
    @NSManaged public var filterMode: String?
    @NSManaged public var filterOptions: [[String: Any]]?
//    filterOptions schema
//    [
//        [
//            "optionType": option type,
//            "optionData": filter option
//        ]
//    ]

}

extension Album: Identifiable {

}

enum AlbumType: String, CaseIterable, Identifiable {
    case simple, smart
    var id: Self { self }
}

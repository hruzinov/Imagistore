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
    @NSManaged public var photosSet: String
    @NSManaged public var title: String
    @NSManaged public var creationDate: Date
    @NSManaged public var filterMode: String?
    @NSManaged public var filterOptionsSet: String? //[[String: Any]]?
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

func optionsToJSON(_ options: [[String: String]]) -> String? {
    do {
        let jsonData = try JSONEncoder().encode(options)
        return String(data: jsonData, encoding: .utf8)
    } catch {
        print(error)
        return nil
    }
}

func JSONToOptions(_ input: String?) -> [[String: String]]? {
    if let input {
        do {
            let jsonData = input.data(using: .utf8)!
            return try JSONDecoder().decode([[String: String]].self, from: jsonData)
        } catch {
            print(error)
            return [[String: String]]()
        }
    } else { return nil }
}

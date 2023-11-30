//
//  Created by Evhen Gruzinov on 07.05.2023.
//

import SwiftUI
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
}

enum PhotoStatus: String, Codable {
    case normal, deleted
}
enum KeywordState {
    case inAll, partical, none
}

extension Photo {

    public class func fetchRequest() -> NSFetchRequest<Photo> {
        NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var uuid: UUID?
    @NSManaged public var libraryID: UUID
    @NSManaged public var status: String
    @NSManaged public var creationDate: Date
    @NSManaged public var importDate: Date
    @NSManaged public var lastChange: Date?
    @NSManaged public var deletionDate: Date?
    @NSManaged public var fileExtension: String?
    @NSManaged public var fullsizeCloudID: String?
    @NSManaged public var keywordsJSON: String?

}

extension Photo: Identifiable {

}

func sortedPhotos(_ photos: FetchedResults<Photo>, by byArgument: PhotosSortArgument, filter: PhotoStatus) -> [Photo] {
    photos
        .filter({ photo in
            photo.uuid != nil
        })
        .filter({ item in
            item.status == filter.rawValue
        })
        .sorted(by: { ph1, ph2 in
            if filter == .deleted, let delDate1 = ph1.deletionDate, let delDate2 = ph2.deletionDate {
                return delDate1 < delDate2
            } else {
                switch byArgument {
                case .importDateDesc:
                    return ph1.importDate > ph2.importDate
                case .creationDateDesc:
                    return ph1.creationDate > ph2.creationDate
                case .importDateAsc:
                    return ph1.importDate < ph2.importDate
                case .creationDateAsc:
                    return ph1.creationDate < ph2.creationDate
                }
            }
        })
    }

func JSONToSet(_ input: String?) -> Set<String>? {
    if let input {
        do {
            let jsonData = input.data(using: .utf8)!
            return try JSONDecoder().decode(Set<String>.self, from: jsonData)
        } catch {
            print(error)
            return Set<String>()
        }
    } else { return nil }
}
func setToJSON(_ input: Set<String>) -> String? {
    do {
        let jsonData = try JSONEncoder().encode(input)
        return String(data: jsonData, encoding: .utf8)
    } catch {
        print(error)
        return nil
    }
}

func JSONToArray(_ input: String?) -> Array<String>? {
    if let input {
        do {
            let jsonData = input.data(using: .utf8)!
            return try JSONDecoder().decode(Array<String>.self, from: jsonData)
        } catch {
            print(error)
            return Array<String>()
        }
    } else { return nil }
}
func arrayToJSON(_ input: Array<String>) -> String? {
    do {
        let jsonData = try JSONEncoder().encode(input)
        return String(data: jsonData, encoding: .utf8)
    } catch {
        print(error)
        return nil
    }
}

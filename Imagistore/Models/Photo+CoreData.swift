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

extension Photo {

    public class func fetchRequest() -> NSFetchRequest<Photo> {
        NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var uuid: UUID?
    @NSManaged public var library: PhotosLibrary
    @NSManaged public var status: String
    @NSManaged public var creationDate: Date
    @NSManaged public var importDate: Date
    @NSManaged public var deletionDate: Date?
    @NSManaged public var fileExtension: String?
    @NSManaged public var miniature: Data?
    @NSManaged public var fullsizeCloudID: String?
    @NSManaged public var keywords: [String]?

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

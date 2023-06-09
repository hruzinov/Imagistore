//
//  Created by Evhen Gruzinov on 07.05.2023.
//

import Foundation
import CoreData

@objc(PhotosLibrary)
public class PhotosLibrary: NSManagedObject {
    static var actualLibraryVersion = 1

    lazy var idPredicate = {
        NSPredicate(format: "uuid = %@", self.uuid as CVarArg)
    }()
}

enum PhotosSortArgument: String {
    case importDateDesc, creationDateDesc
    case importDateAsc, creationDateAsc
}

enum RemovingDirection: String {
    case bin
    case recover
    case permanent
}

//
//  Created by Evhen Gruzinov on 03.06.2023.
//

import Foundation
import CoreData

@objc(Album)
public class Album: NSManagedObject {

}

enum AlbumType: String, CaseIterable, Identifiable {
    case simple, smart
    var id: Self { self }
}

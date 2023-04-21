//
//  Created by Evhen Gruzinov on 20.04.2023.
//

import Foundation

class DBUser: Codable {
    let username: String
    let libraries: [String]
}

class DBLibrary: Codable {
    var id: String
    var name: String
    var libraryVersion: Int
    var lastChangeDate: Date
    var photos: [String]
}

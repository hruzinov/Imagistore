//
//  Created by Evhen Gruzinov on 08.04.2023.
//

import Foundation

struct ApplicationSettings {
    static var actualLibraryVersion = 1
}

class DispayingSettings: ObservableObject {
    @Published var isShowingTabBar: Bool = true
    
    @Published var isShowingErrorAlert: Bool = false
    @Published var errorAlertData: String = ""
}

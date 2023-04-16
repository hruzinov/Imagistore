//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI

@main
struct GallerysticApp: App {
    var body: some Scene {
        WindowGroup {
            SceneNavigatorView()
                .environmentObject(DispayingSettings())
        }
    }
}
    

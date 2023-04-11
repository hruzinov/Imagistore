//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI

@main
struct GallerysticApp: App {
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(DispayingSettings())
        }
    }
}

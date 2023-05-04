//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI

@main
struct GallerysticApp: App {
    @State var uiImageHolder: UIImageHolder = UIImageHolder()
    
    var body: some Scene {
        WindowGroup {
            AppNavigator()
                .environmentObject(SceneSettings())
        }
    }
}

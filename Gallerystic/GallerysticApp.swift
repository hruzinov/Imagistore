//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI

@main
struct GallerysticApp: App {
    @State var photosLibrary = loadLibrary()
    
    var body: some Scene {
        WindowGroup {
            ContentView(library: $photosLibrary)
                .preferredColorScheme(.dark)
        }
    }
}

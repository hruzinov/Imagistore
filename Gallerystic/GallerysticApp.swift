//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI

@main
struct GallerysticApp: App {
    @State var photosLibrary = loadLibrary()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                GallerySceneView(library: $photosLibrary, photosSelector: .normal, canAddNewPhotos: true)
                    .tabItem {
                        Label("Library", systemImage: "photo.artframe")
                    }
                AlbumsSceneView(library: $photosLibrary)
                    .tabItem {
                        Label("Albums", systemImage: "sparkles.rectangle.stack")
                    }
            }
        }
    }
}

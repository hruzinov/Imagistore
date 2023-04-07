//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI

@main
struct GallerysticApp: App {
    @State var photosLibrary = loadLibrary()
    @State var selectedTab = "library"
    @State var navToRoot: Bool = false
    
    var handler: Binding<String> { Binding(
        get: { self.selectedTab },
        set: {
            if $0 == self.selectedTab {
                navToRoot = true
            }
            self.selectedTab = $0
        }
    )}
    
    var body: some Scene {
        WindowGroup {
            TabView(selection: handler) {
                GallerySceneView(library: $photosLibrary, photosSelector: .normal, canAddNewPhotos: true, navToRoot: $navToRoot)
                    .tabItem {
                        Label("Library", systemImage: "photo.artframe")
                    }
                    .tag("library")
                AlbumsSceneView(library: $photosLibrary, navToRoot: $navToRoot)
                    .tabItem {
                        Label("Albums", systemImage: "sparkles.rectangle.stack")
                    }
                    .tag("albums")
                    
            }
        }
    }
}

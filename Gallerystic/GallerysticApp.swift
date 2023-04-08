//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI

@main
struct GallerysticApp: App {
    @State var photosLibrary = loadLibrary()
    @State var selectedTab: Tab = .library
    @State var navToRoot: Bool = false
    
    var handler: Binding<Tab> { Binding(
        get: { self.selectedTab },
        set: {
            if $0 == self.selectedTab {
                navToRoot = true
            }
            self.selectedTab = $0
        }
    )}
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some Scene {
        WindowGroup {
            VStack {
                TabView(selection: handler) {
                    GallerySceneView(library: $photosLibrary, photosSelector: .normal, canAddNewPhotos: true, navToRoot: $navToRoot)
                        .tabItem {
                            Label("Library", systemImage: "photo.artframe")
                        }
                        .tag(Tab.library)
                    AlbumsSceneView(library: $photosLibrary, navToRoot: $navToRoot)
                        .tabItem {
                            Label("Albums", systemImage: "sparkles.rectangle.stack")
                        }
                        .tag(Tab.albums)
                }
                .overlay(alignment: .bottom){
                    CustomTabBar(selection: handler)
                }
            }
            .environmentObject(DispayingSettings())
        }
    }
}

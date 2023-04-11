//
//  Created by Evhen Gruzinov on 10.04.2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var photosLibrary = loadLibrary()
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
    
    var body: some View {
        VStack {
            TabView(selection: handler) {
                GallerySceneView(library: photosLibrary, photosSelector: .normal, canAddNewPhotos: true, navToRoot: $navToRoot)
                    .tabItem {
                        Label("Library", systemImage: "photo.artframe")
                    }
                    .tag(Tab.library)
                AlbumsSceneView(library: photosLibrary, navToRoot: $navToRoot)
                    .tabItem {
                        Label("Albums", systemImage: "sparkles.rectangle.stack")
                    }
                    .tag(Tab.albums)
            }
            .overlay(alignment: .bottom){
                CustomTabBar(selection: handler)
            }
        }
    }
}

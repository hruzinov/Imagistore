//
//  Created by Evhen Gruzinov on 10.04.2023.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dispayingSettings: DispayingSettings
    @StateObject var photosLibrary = loadLibrary()
    @State var selectedTab: Tab = .library
    @State var navToRoot: Bool = false
    
    var handler: Binding<Tab> { Binding(
        get: { self.selectedTab },
        set: {
            if $0 == self.selectedTab { navToRoot = true }
            self.selectedTab = $0
        }
    )}
    
    var body: some View {
        VStack {
            TabView(selection: handler) {
                GallerySceneView(library: photosLibrary, photosSelector: .normal, canAddNewPhotos: true, navToRoot: $navToRoot)
                    .tag(Tab.library)
                AlbumsSceneView(library: photosLibrary, navToRoot: $navToRoot)
                    .tag(Tab.albums)
            }
            .overlay(alignment: .bottom){
                CustomTabBar(selection: handler)
            }
        }
        .alert(dispayingSettings.errorAlertData, isPresented: $dispayingSettings.isShowingErrorAlert){}
    }
}

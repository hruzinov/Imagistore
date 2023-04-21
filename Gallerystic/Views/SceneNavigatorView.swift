//
//  Created by Evhen Gruzinov on 16.04.2023.
//

import SwiftUI

struct SceneNavigatorView: View {
    @State var librariesCollection: PhotosLibrariesCollection?
    @State var photosLibrary: PhotosLibrary?
    @State var applicationSettings = ApplicationSettings()
    @State var loaded = false
    @EnvironmentObject var dispayingSettings: DispayingSettings
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack {
            if loaded {
                if applicationSettings.isFirstLaunch {
                    LoginSceneView(applicationSettings: $applicationSettings)
                } else if let photosLibrary {
                    ContentView(photosLibrary: photosLibrary, applicationSettings: $applicationSettings)
                } else if librariesCollection != nil {
                    LibrariesSelectorView(applicationSettings: $applicationSettings, librariesCollection: $librariesCollection, selectedLibrary: $photosLibrary)
                } else {
                    ProgressView("Loading...")
                        .progressViewStyle(.circular)
                        .padding(50)
                }
            } else {
                ProgressView("Loading...")
                    .progressViewStyle(.circular)
                    .padding(50)
            }
        }
        .onAppear {
            applicationSettings.load()
            DispatchQueue.main.async {
                withAnimation {
//                    if let libId = applicationSettings.lastSelectedLibrary {
//                        photosLibrary = loadLibrary(id: libId)
//                    } else {
                        librariesCollection = loadLibrariesCollection()
//                    }
                    loaded.toggle()
                }
            }
        }
    }
}

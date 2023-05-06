//
//  Created by Evhen Gruzinov on 16.04.2023.
//

import SwiftUI

struct AppNavigator: View {
    @State var librariesCollection: PhotosLibrariesCollection?
    @State var photosLibrary: PhotosLibrary?
    @State var applicationSettings = ApplicationSettings()
    @StateObject var imageHolder: UIImageHolder = UIImageHolder()
    @State var loaded = false
    @EnvironmentObject var sceneSettings: SceneSettings

    init() {
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        ZStack {
            if loaded {
                //                if applicationSettings.isFirstLaunch {
                //                    LoginSceneView(applicationSettings: $applicationSettings)
                //                } else
                if let photosLibrary {
                    ContentView(photosLibrary: photosLibrary,
                                applicationSettings: $applicationSettings, imageHolder: imageHolder)
                } else if librariesCollection != nil {
                    LibrariesSelectorView(applicationSettings: $applicationSettings,
                                          librariesCollection: $librariesCollection, selectedLibrary: $photosLibrary)
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
                    if let libId = applicationSettings.lastSelectedLibrary {
                        let lastLibrary = loadLibrary(id: libId)
                        if let lastLibrary {
                            photosLibrary = lastLibrary
                        } else {
                            applicationSettings.lastSelectedLibrary = nil
                            applicationSettings.save()
                            librariesCollection = loadLibrariesCollection()
                        }
                    } else {
                        librariesCollection = loadLibrariesCollection()
                    }
                    loaded.toggle()
                }
            }
        }
    }
}

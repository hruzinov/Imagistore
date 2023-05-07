//
//  Created by Evhen Gruzinov on 16.04.2023.
//

import SwiftUI
import CoreData

struct AppNavigator: View {
//    @FetchRequest(sortDescriptors: []) var librariesCollection: FetchedResults<CoreDataLibrary>

//    @State var librariesCollection: PhotosLibrariesCollection?
    @State var photosLibrary: PhotosLibrary?
    @State var photos: [Photo]?
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
                if let photosLibrary, let photos {
                    ContentView(photosLibrary: photosLibrary, photos: photos,
                                applicationSettings: $applicationSettings, imageHolder: imageHolder)
                } else {
                    LibrariesSelectorView(applicationSettings: $applicationSettings, selectedLibrary: $photosLibrary, photos: $photos)
//                } else {
//                    ProgressView("Loading...")
//                        .progressViewStyle(.circular)
//                        .padding(50)
                }
            } else {
                ProgressView("Loading...")
                    .progressViewStyle(.circular)
                    .padding(50)
            }
        }
        .onAppear {
//            applicationSettings.load()
//            DispatchQueue.main.async {
//                withAnimation {
//                    if let libId = applicationSettings.lastSelectedLibrary {
//                        let lastLibrary = loadLibrary(id: libId)
//                        if let lastLibrary {
//                            photosLibrary = lastLibrary
//                        } else {
//                            applicationSettings.lastSelectedLibrary = nil
//                            applicationSettings.save()
//                            librariesCollection = loadLibrariesCollection()
//                        }
//                    } else {
//                        librariesCollection = loadLibrariesCollection()
//                    }
                    loaded.toggle()
//                }
//            }
        }
    }
}

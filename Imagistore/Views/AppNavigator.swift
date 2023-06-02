//
//  Created by Evhen Gruzinov on 16.04.2023.
//

import SwiftUI
import CoreData

struct AppNavigator: View {
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
                if let photosLibrary {
                    ContentView(photosLibrary: photosLibrary,
                                photos: FetchRequest(sortDescriptors: [],
                                        predicate: NSPredicate(format: "library = %@", photosLibrary)),
                                        applicationSettings: $applicationSettings, imageHolder: imageHolder)
                } else {
                    LibrariesSelectorView(applicationSettings: $applicationSettings, selectedLibrary: $photosLibrary)
                }
            } else {
                ProgressView("Loading...")
                    .progressViewStyle(.circular)
                    .padding(50)
            }
        }
        .alert(sceneSettings.errorAlertData, isPresented: $sceneSettings.isShowingErrorAlert) {}
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

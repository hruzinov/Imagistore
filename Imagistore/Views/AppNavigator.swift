//
//  Created by Evhen Gruzinov on 16.04.2023.
//

import SwiftUI
import CoreData

struct AppNavigator: View {
    @State var photosLibrary: PhotosLibrary?
    @State var applicationSettings = ApplicationSettings()
    @State var loaded = false
    @State var goToPhotosLibrary = false
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
                                                     predicate: NSPredicate(format: "libraryID = %@", photosLibrary.uuid as CVarArg)),
                                albums: FetchRequest(sortDescriptors: [],
                                        predicate: NSPredicate(format: "library = %@", photosLibrary.uuid as CVarArg)),
                                miniatures: FetchRequest(sortDescriptors: [],
                                        predicate: NSPredicate(format: "library = %@", photosLibrary.uuid as CVarArg)),
                                goToPhotosLibrary: $goToPhotosLibrary, applicationSettings: $applicationSettings)
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
        .onChange(of: goToPhotosLibrary, perform: { _ in
            if goToPhotosLibrary {
                goToPhotosLibrary.toggle()
                photosLibrary = nil
            }
        })
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

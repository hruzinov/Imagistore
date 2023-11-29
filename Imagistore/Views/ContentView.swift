//
//  Created by Evhen Gruzinov on 10.04.2023.
//

import SwiftUI
import CloudKit
import CoreData

struct ContentView: View {
    @StateObject var photosLibrary: PhotosLibrary
    @EnvironmentObject var sceneSettings: SceneSettings
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest var photos: FetchedResults<Photo>
    @FetchRequest var albums: FetchedResults<Album>

    @State var sortingArgument: PhotosSortArgument = .importDateDesc
    @State var selectedTab: Tab = .library
    @State var navToRoot: Bool = false
    @Binding var goToPhotosLibrary: Bool
    @State var viewLoaded: Bool = false

    @Binding var applicationSettings: ApplicationSettings

    var handler: Binding<Tab> { Binding(
        get: { selectedTab },
        set: {
            if $0 == .albums && $0 == selectedTab { navToRoot = true }
            self.selectedTab = $0
        }
    )}

    var body: some View {
        if viewLoaded {
            VStack {
                TabView(selection: handler) {
                    GallerySceneView(library: photosLibrary, photos: photos, albums: albums,
                                     sortingArgument: $sortingArgument,
                                     navToRoot: $navToRoot, photosSelector: .normal, isMainLibraryScreen: true)
                    .tag(Tab.library)
                    AlbumsSceneView(library: photosLibrary, photos: photos, albums: albums,
                                    sortingArgument: $sortingArgument, navToRoot: $navToRoot)
                    .tag(Tab.albums)
                    SettingsSceneView(goToPhotosLibrary: $goToPhotosLibrary)
                    .tag(Tab.settings)
                }
                .overlay(alignment: .bottom) {
                    CustomTabBar(selection: handler)
                }
                .toolbar(.hidden, for: .tabBar)
            }
            .task {
                Task {
//                    for photo in photos {
//                        let newMiniature = Miniature(context: viewContext)
//                        newMiniature.uuid = photo.uuid!
//                        newMiniature.miniature = photo.miniature!
//                        photo.lastChange = Date.now
//                        try! viewContext.save()
//                    }
//                    print("ALL GOOD")
                }
            }
            .overlay(alignment: .center, content: {
                if sceneSettings.isShowingInfoBar {
                    UICircleProgressPupUp(progressText: $sceneSettings.infoBarData,
                                          progressValue: $sceneSettings.infoBarProgress,
                                          progressFinal: $sceneSettings.infoBarFinal)
                }
            })
        } else {
            ProgressView("Loading library...").progressViewStyle(.circular)
                .task {
                    DispatchQueue.main.async {
                        Task {
                            photosLibrary.clearBin(in: viewContext) { err in
                                if let err {
                                    sceneSettings.errorAlertData = err.localizedDescription
                                    sceneSettings.isShowingErrorAlert.toggle()
                                }
                            }
//                            if await imageHolder.getAllUiImages(photos) {
                                viewLoaded.toggle()
//                            }
                        }
                    }
                }
        }
    }
}

func saveToCloudKit() {

//    let photoCloudRecord = CKRecord(recordType: "FullSizePhotos")
//    photoCloudRecord["library"] = library.uuid.uuidString as CKRecordValue
//    photoCloudRecord["photo"] = uuid.uuidString as CKRecordValue
//    photoCloudRecord["asset"] = imageAsset
//    newPhoto.fullsizeCloudID = photoCloudRecord.recordID.recordName
//    syncArr.append(uuid)
//    cloudRecords.append(photoCloudRecord)
}

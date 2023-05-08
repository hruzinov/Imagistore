//
//  Created by Evhen Gruzinov on 10.04.2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var photosLibrary: PhotosLibrary
    @EnvironmentObject var sceneSettings: SceneSettings
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: []) var photos: FetchedResults<Photo>

    @State var sortingArgument: PhotosSortArgument = .importDate
    @State var selectedTab: Tab = .library
    @State var navToRoot: Bool = false

    @Binding var applicationSettings: ApplicationSettings
    @StateObject var imageHolder: UIImageHolder

    var handler: Binding<Tab> { Binding(
        get: { selectedTab },
        set: {
            if $0 == selectedTab { navToRoot = true }
            self.selectedTab = $0
        }
    )}

    var body: some View {
        VStack {
            TabView(selection: handler) {
                GallerySceneView(library: photosLibrary, photos: photos, sortingArgument: $sortingArgument,
                                 imageHolder: imageHolder, navToRoot: $navToRoot,
                                 photosSelector: .normal, isMainLibraryScreen: true)
                .tag(Tab.library)
                AlbumsSceneView(library: photosLibrary, sortingArgument: $sortingArgument,
                                navToRoot: $navToRoot, imageHolder: imageHolder, photos: photos)
                .tag(Tab.albums)
            }
            .overlay(alignment: .bottom) {
                CustomTabBar(selection: handler)
            }
            .toolbar(.hidden, for: .tabBar)
        }
        .overlay(alignment: .center, content: {
            if sceneSettings.isShowingInfoBar {
                UICircleProgressPupUp(progressText: $sceneSettings.infoBarData,
                                      progressValue: $sceneSettings.infoBarProgress,
                                      progressFinal: $sceneSettings.infoBarFinal)
            }
        })
        //        .onAppear {
        //            photosLibrary.clearBin(photosLibrary) { err in
        //                if let err {
        //                    sceneSettings.errorAlertData = err.localizedDescription
        //                    sceneSettings.isShowingErrorAlert.toggle()
        //                }
        //            }
        //        }
        .alert(sceneSettings.errorAlertData, isPresented: $sceneSettings.isShowingErrorAlert) {}
    }
}

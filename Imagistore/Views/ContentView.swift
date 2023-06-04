//
//  Created by Evhen Gruzinov on 10.04.2023.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject var photosLibrary: PhotosLibrary
    @EnvironmentObject var sceneSettings: SceneSettings
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest var photos: FetchedResults<Photo>
    @FetchRequest var albums: FetchedResults<Album>

    @State var sortingArgument: PhotosSortArgument = .importDate
    @State var selectedTab: Tab = .library
    @State var navToRoot: Bool = false
    @State var scrollToBottom: Bool = false

    @Binding var applicationSettings: ApplicationSettings
    @StateObject var imageHolder: UIImageHolder

    var handler: Binding<Tab> { Binding(
        get: { selectedTab },
        set: {
            if $0 == .library && $0 == selectedTab { scrollToBottom = true }
            else if $0 == .albums && $0 == selectedTab { navToRoot = true }
            self.selectedTab = $0
        }
    )}

    var body: some View {
        VStack {
            TabView(selection: handler) {
                GallerySceneView(library: photosLibrary, photos: photos, albums: albums, sortingArgument: $sortingArgument,
                                 imageHolder: imageHolder, navToRoot: $navToRoot, scrollToBottom: $scrollToBottom,
                                 photosSelector: .normal, isMainLibraryScreen: true)
                .tag(Tab.library)
                AlbumsSceneView(library: photosLibrary, photos: photos, albums: albums, sortingArgument: $sortingArgument,
                                navToRoot: $navToRoot, imageHolder: imageHolder)
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
        .onAppear {
            photosLibrary.clearBin(in: viewContext) { err in
                if let err {
                    sceneSettings.errorAlertData = err.localizedDescription
                    sceneSettings.isShowingErrorAlert.toggle()
                }
            }
        }
    }
}

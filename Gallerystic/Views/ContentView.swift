//
//  Created by Evhen Gruzinov on 10.04.2023.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ContentView: View {
    @StateObject var photosLibrary: PhotosLibrary
    
    @EnvironmentObject var dispayingSettings: DispayingSettings
    @Binding var applicationSettings: ApplicationSettings
    
    @Binding var uiImageHolder: UIImageHolder
    @State var sortingSelector: PhotosSortArgument = .importDate
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
                GallerySceneView(library: photosLibrary, photosSelector: .normal, isMainLibraryScreen: true, sortingSelector: $sortingSelector, uiImageHolder: $uiImageHolder, navToRoot: $navToRoot)
                    .tag(Tab.library)
                AlbumsSceneView(library: photosLibrary, sortingSelector: $sortingSelector, navToRoot: $navToRoot, uiImageHolder: $uiImageHolder)
                    .tag(Tab.albums)
            }
            .overlay(alignment: .bottom){
                CustomTabBar(selection: handler)
            }
            .toolbar(.hidden, for: .tabBar)
        }
        .overlay(alignment: .center, content: {
            if dispayingSettings.isShowingInfoBar {
                UICircleProgressPupup(progressText: $dispayingSettings.infoBarData, progressValue: $dispayingSettings.infoBarProgress, progressFinal: $dispayingSettings.infoBarFinal)
            }
        })
        .onAppear {
            photosLibrary.clearBin() { err in
                if let err {
                    dispayingSettings.errorAlertData = err.localizedDescription
                    dispayingSettings.isShowingErrorAlert.toggle()
                }
            }
        }
        .alert(dispayingSettings.errorAlertData, isPresented: $dispayingSettings.isShowingErrorAlert){}
    }
}

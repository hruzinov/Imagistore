//
//  Created by Evhen Gruzinov on 16.04.2023.
//

import SwiftUI

struct SceneNavigatorView: View {
    @State var photosLibrary: PhotosLibrary?
    @State var applicationSettings = ApplicationSettings()
    @EnvironmentObject var dispayingSettings: DispayingSettings
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack {
            if let photosLibrary {
                ContentView(photosLibrary: photosLibrary)
            } else {
                ProgressView("Loading library")
                    .progressViewStyle(.circular)
                    .padding(50)
            }
        }
        .onAppear {
            DispatchQueue.main.async {
                photosLibrary = loadLibrary()
            }
        }
    }
}

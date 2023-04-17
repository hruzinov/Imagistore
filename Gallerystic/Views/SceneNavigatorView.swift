//
//  Created by Evhen Gruzinov on 16.04.2023.
//

import SwiftUI
import RealmSwift

struct SceneNavigatorView: View {
    @ObservedResults(PhotosLibrary.self) var photosLibrary
    @EnvironmentObject var dispayingSettings: DispayingSettings
    @State var uiImageHolder: UIImageHolder = UIImageHolder()
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack {
            if let photosLibrary = photosLibrary.first {
                ContentView(photosLibrary: photosLibrary, uiImageHolder: $uiImageHolder)
            } else {
                ProgressView("Loading library")
                    .progressViewStyle(.circular)
                    .padding(50)
                    .onAppear {
                        $photosLibrary.append(PhotosLibrary())
                    }
            }
        }
    }
}

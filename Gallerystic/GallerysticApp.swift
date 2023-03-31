//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI

@main
struct GallerysticApp: App {
    @State var photosLibrary = loadLibrary()
    
    var body: some Scene {
        WindowGroup {
            GallerySceneView(library: $photosLibrary)
//                .preferredColorScheme(.dark)/
//                .onAppear {
//                    print(photosLibrary)
//                    var sortedLibrary = photosLibrary
//                    var newPhotos = photosLibrary.photos.sorted {
//                        $0.creationDate < $1.creationDate
//                    }
//                    sortedLibrary.photos = newPhotos
//                    photosLibrary = sortedLibrary
//                    print(photosLibrary)
//                }
        }
    }
}

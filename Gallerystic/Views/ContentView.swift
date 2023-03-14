//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @Binding var library: PhotosLibrary
    @State private var importSelectedItems = [PhotosPickerItem]()
    
    var body: some View {
        NavigationView {
            VStack {
                PhotosGalleryView(library: $library)
            }
            .toolbar {
                PhotosPicker(
                    selection: $importSelectedItems,
                    matching: .images,
                    photoLibrary: .shared()
                ) { Image(systemName: "plus") }
                    .onChange(of: importSelectedItems) { _ in
                        Task {
                            for item in importSelectedItems {
                                if let data = try? await item.loadTransferable(type: Data.self) {
                                    let uiImage = UIImage(data: data)
                                    if let uiImage {
                                        let creationDate: Date
                                        if let localID = item.itemIdentifier {
                                            let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localID], options: nil).firstObject
                                            creationDate = asset?.creationDate ?? Date()
                                        } else {
                                            creationDate = Date()
                                        }
                                        let uuid = writeImageToFile(uiImage: uiImage)
                                        if let uuid {
                                            library.addImages([Photo(id: uuid, status: .normal, creationDate: creationDate, keywords: [])])
                                        }
                                    }
                                }
                            }
                            saveLibrary(lib: library)
                            importSelectedItems = []
                        }
                    }
            }
        }
        .onAppear {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { _ in
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(library: .constant(PhotosLibrary(photos: [Photo])))
//    }
//}

//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI
import PhotosUI

struct GallerySceneView: View {
    @Binding var library: PhotosLibrary
    @State var photosSelector: PhotoStatus
    @State var canAddNewPhotos: Bool = false
//    @State var selectedImage: Photo?
    @State private var importSelectedItems = [PhotosPickerItem]()
    @State var showGalleryOverlay: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                PhotosGalleryView(library: $library, photosSelector: photosSelector)
//                PhotosGalleryView(library: $library, selectedImage: $selectedImage)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if canAddNewPhotos {
                    ToolbarItem(placement: .navigationBarLeading) {
                        PhotosPicker(
                            selection: $importSelectedItems,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            Image(systemName: "plus")
                        }
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
                                                library.addImages([Photo(id: uuid, status: .normal, creationDate: creationDate, importDate: Date(), keywords: [])])
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        
                    } label: {
                        Image(systemName: "ellipsis.circle")
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

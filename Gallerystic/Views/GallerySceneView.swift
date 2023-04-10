//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI
import PhotosUI

struct GallerySceneView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var library: PhotosLibrary
    @State var photosSelector: PhotoStatus
    @State var canAddNewPhotos: Bool = false
    @State var sortingSelector: PhotosSortArgument = .importDate
    @State private var importSelectedItems = [PhotosPickerItem]()
    @State var showGalleryOverlay: Bool = false
    @Binding var navToRoot: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                if library.photos.filter({ ph in
                    ph.status == photosSelector
                }).count > 0 {
                    PhotosGalleryView(library: $library, photosSelector: photosSelector, sortingSelector: $sortingSelector)
                    Rectangle()
                        .frame(height: 50)
                        .opacity(0)
                } else {
                    Text(Int.random(in: 1...100) == 7 ? "These aren't the photos you're looking for." : "No photos or videos here").font(.title2).bold()
                }
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
                                var newPhotos: [Photo] = []
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
                                            
                                            let fileExtention: PhotoExtention
                                            if let format = item.supportedContentTypes.first?.identifier, format == "public.png" {
                                                fileExtention = .png
                                            } else {
                                                fileExtention = .jpg
                                            }
                                            
                                            let uuid = writeImageToFile(uiImage: uiImage, fileExtention: fileExtention.rawValue)
                                            if let uuid {
                                                newPhotos.append(Photo(id: uuid, status: .normal, creationDate: creationDate, importDate: Date(), fileExtention: fileExtention, keywords: []))
                                            }
                                        }
                                    }
                                }
                                library.addImages(newPhotos)
                                importSelectedItems = []
                            }
                        }
                    }
                }
                ToolbarItemGroup (placement: .navigationBarTrailing) {
                    Menu {
                        Picker(selection: $sortingSelector.animation()) {
                            Text("Creation date").tag(PhotosSortArgument.creationDate)
                            Text("Importing date").tag(PhotosSortArgument.importDate)
                        } label: {}
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
        }
        
        .onAppear {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { _ in
            }
        }
        .onChange(of: navToRoot) { _ in
            dismiss()
            navToRoot = false
        }
    }
}

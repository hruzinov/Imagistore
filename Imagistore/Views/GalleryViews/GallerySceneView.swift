//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI
import PhotosUI

struct GallerySceneView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var sceneSettings: SceneSettings
    @ObservedObject var library: PhotosLibrary

    @Binding var sortingSelector: PhotosSortArgument
    @ObservedObject var uiImageHolder: UIImageHolder
    @Binding var navToRoot: Bool

    @State private var importSelectedItems = [PhotosPickerItem]()
    @State var photosSelector: PhotoStatus
    @State var isMainLibraryScreen: Bool = false
    @State var showGalleryOverlay: Bool = false
    @State var selectedImage: Photo?
    @State var selectingMode: Bool = false
    @State var selectedImagesArray: [Photo] = []
    @State var isPresentingConfirm: Bool = false
    @State var scrollTo: UUID?

    var body: some View {
        NavigationStack {
            VStack {
                if library.photos.filter({ img in
                    img.status == photosSelector
                }).count > 0 {
                    UIGalleryView(
                            library: library,
                            photosSelector: photosSelector,
                            sortingSelector: $sortingSelector,
                            uiImageHolder: uiImageHolder,
                            scrollTo: $scrollTo,
                            selectingMode: $selectingMode,
                            selectedImagesArray: $selectedImagesArray,
                            isMainLibraryScreen: isMainLibraryScreen
                    )
                } else {
                    Text(Int.random(in: 1...100) == 7 ?
                            "These aren't the photos you're looking for." :
                            "No photos or videos here")
                            .font(.title2)
                            .bold()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .confirmationDialog("Delete \(selectedImagesArray.count) photos", isPresented: $isPresentingConfirm) {
                Button("Delete photos", role: .destructive) {
                    if photosSelector == .deleted {
                        changePhotoStatus(to: .permanent)
                    } else {
                        changePhotoStatus(to: .bin)
                    }
                }
            } message: {
                if photosSelector == .deleted {
                    Text("You cannot undo this action")
                }
            }
            .toolbar {
                if isMainLibraryScreen, !selectingMode {
                    ToolbarItem(placement: .navigationBarLeading) {
                        PhotosPicker(
                            selection: $importSelectedItems,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            Image(systemName: "plus")
                        }
                        .onChange(of: importSelectedItems) { _ in
                            if importSelectedItems.count > 0 {
                                importFromPhotosApp()
                            }
                        }
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        selectingMode.toggle()
                        if selectingMode {
                            sceneSettings.isShowingTabBar = false
                        } else {
                            sceneSettings.isShowingTabBar = true
                            selectedImagesArray = []
                        }
                    } label: {
                        Text(selectingMode ? "Cancel" : "Select")
                    }
                    if photosSelector != .deleted, !selectingMode {
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
                if selectingMode {
                    ToolbarItemGroup(placement: .bottomBar) {
                        if photosSelector == .deleted {
                            Button { isPresentingConfirm.toggle() } label: { Text("Delete") }
                                .disabled(selectedImagesArray.count==0)
                            Spacer()
                            Text(selectedImagesArray.count > 0 ?
                                    "\(selectedImagesArray.count) selected" : "Select photos"
                            )
                                    .bold()
                            Spacer()
                            Button { changePhotoStatus(to: .recover) } label: { Text("Recover") }
                                .disabled(selectedImagesArray.count==0)
                        } else {
                            Spacer()
                            Text(selectedImagesArray.count > 0 ?
                                    "\(selectedImagesArray.count) selected" : "Select photos"
                            )
                                    .bold()
                            Spacer()
                            Button { isPresentingConfirm.toggle() } label: { Image(systemName: "trash") }
                                .disabled(selectedImagesArray.count==0)
                        }
                    }
                }
            }
        }
        .onAppear {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { _ in
            }
        }
        .onDisappear {
            if selectingMode {
                sceneSettings.isShowingTabBar = true
                selectingMode.toggle()
                selectedImagesArray = []
            }
        }
        .onChange(of: navToRoot) { _ in
            dismiss()
            navToRoot = false
        }
    }

    private func changePhotoStatus(to direction: RemovingDirection) {
        withAnimation {
            switch direction {
            case .bin:
                library.toBin(selectedImagesArray) { err in
                    if let err {
                        sceneSettings.errorAlertData = err.localizedDescription
                        sceneSettings.isShowingErrorAlert.toggle()
                    }
                }
            case .recover:
                library.recoverImages(selectedImagesArray) { err in
                    if let err {
                        sceneSettings.errorAlertData = err.localizedDescription
                        sceneSettings.isShowingErrorAlert.toggle()
                    }
                }
            case .permanent:
                library.permanentRemove(selectedImagesArray, library: library) { err in
                    if let err {
                        sceneSettings.errorAlertData = err.localizedDescription
                        sceneSettings.isShowingErrorAlert.toggle()
                    }
                }
            }
        }
        sceneSettings.isShowingTabBar = true
        selectingMode.toggle()
        selectedImagesArray = []
    }

    private func importFromPhotosApp() {
        Task {
            sceneSettings.infoBarData = "Importing..."
            sceneSettings.infoBarFinal = false
            let importCount = importSelectedItems.count
            withAnimation { sceneSettings.isShowingInfoBar.toggle() }
            var count = 0
            var newPhotos: [Photo] = []
            for item in importSelectedItems {
                withAnimation {
                    sceneSettings.infoBarProgress = Double(count) / Double(importSelectedItems.count)
                }

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

                        let fileExtension: PhotoExtension
                        if let format = item.supportedContentTypes.first?.identifier, format == "public.png" {
                            fileExtension = .png
                        } else {
                            fileExtension = .jpg
                        }

                        let uuid = writeImageToFile(uiImage: uiImage, library: library)
                        if let uuid {
                            newPhotos.append(Photo(id: uuid, status: .normal, creationDate: creationDate,
                                    importDate: Date(), fileExtension: fileExtension, keywords: []))
                            count += 1
                        }
                    }
                }
            }
            withAnimation {
                library.addImages(newPhotos) { finalCount, err in
                    if let err {
                        sceneSettings.errorAlertData = err.localizedDescription
                        sceneSettings.isShowingErrorAlert.toggle()
                    } else {
                        scrollTo = newPhotos.last?.id
                        sceneSettings.infoBarFinal = true
                        sceneSettings.infoBarData = "\(finalCount) photos saved"
                        sceneSettings.infoBarProgress = Double(finalCount) / Double(importCount)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation { sceneSettings.isShowingInfoBar.toggle() }
                        }
                    }
                }
            }
            importSelectedItems = []
        }
    }
    private func loadDataFromPhotos(_ importSelectedItems: [PhotosPickerItem]) async -> [Photo] {
        var newPhotos = [Photo]()
        var count = 0
        for item in importSelectedItems {
            withAnimation {
                sceneSettings.infoBarProgress = Double(count) / Double(importSelectedItems.count)
            }
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
                    let fileExtension: PhotoExtension
                    if let format = item.supportedContentTypes.first?.identifier, format == "public.png" {
                        fileExtension = .png
                    } else {
                        fileExtension = .jpg
                    }
                    let uuid = writeImageToFile(uiImage: uiImage, library: library)
                    if let uuid {
                        newPhotos.append(
                                Photo(
                                        id: uuid,
                                        status: .normal,
                                        creationDate: creationDate,
                                        importDate: Date(),
                                        fileExtension: fileExtension,
                                        keywords: []
                                )
                        )
                        count += 1
                    }
                }
            }
        }
        return newPhotos
    }
}

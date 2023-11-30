//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI
import PhotosUI
import CloudKit

struct GallerySceneView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var sceneSettings: SceneSettings
    @StateObject var library: PhotosLibrary
    var photos: FetchedResults<Photo>
    var albums: FetchedResults<Album>
    var miniatures: FetchedResults<Miniature>
    @State var currentAlbum: Album?

    @Binding var sortingArgument: PhotosSortArgument
    @Binding var navToRoot: Bool

    @State private var importSelectedItems = [PhotosPickerItem]()
    @State var photosSelector: PhotoStatus
    @State var isMainLibraryScreen: Bool = false
    @State var showGalleryOverlay: Bool = false
    @State var selectedImage: Photo?
    @State var selectingMode: Bool = false
    @State var selectedImagesArray: [Photo] = []
    @State var isPresentingDeletePhotos: Bool = false
    @State var isPresentingDeleteAlbum: Bool = false
    @State var isPresentingAddToAlbum: Bool = false
    @State var isPresentingEditTags: Bool = false
    @State var isPhotosChanged: Bool = false
    @State var scrollTo: UUID?
    @State var syncArr = [UUID]()

    var body: some View {
        NavigationStack {
            VStack {
                UIGalleryView(
                    library: library,
                    photos: photos,
                    albums: albums,
                    miniatures: miniatures,
                    currentAlbum: currentAlbum,
                    photosSelector: photosSelector,
                    sortingArgument: $sortingArgument,
                    scrollTo: $scrollTo,
                    selectingMode: $selectingMode,
                    selectedImagesArray: $selectedImagesArray,
                    syncArr: $syncArr,
                    isMainLibraryScreen: isMainLibraryScreen
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .confirmationDialog("Delete \(selectedImagesArray.count) photos", isPresented: $isPresentingDeletePhotos) {
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
            .confirmationDialog("Delete album \(currentAlbum?.title ?? "")", isPresented: $isPresentingDeleteAlbum) {
                Button("Delete", role: .destructive) {
                    if let currentAlbum {
                        dismiss()
                        viewContext.delete(currentAlbum)
                        if let index = library.albums?.firstIndex(where: { $0 == currentAlbum.uuid }) {
                            library.albums?.remove(at: index)
                        }
                        do {
                            try viewContext.save()
                        } catch {
                            sceneSettings.errorAlertData = error.localizedDescription
                            sceneSettings.isShowingErrorAlert.toggle()
                        }
                    }
                }
            } message: {
                Text("You cannot undo this action. Photos will not be deleted")
            }
            .toolbar {
                if isMainLibraryScreen, !selectingMode {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
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

                        if syncArr.count > 0 {
                            withAnimation {
                                HStack(spacing: 5) {
                                    Text("\(syncArr.count) in sync").font(.caption).bold()
                                    ProgressView()
                                }
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
                        Image(systemName: selectingMode ? "xmark.circle" : "checkmark.circle")
                    }
                    if photosSelector != .deleted, !selectingMode {
                        Menu {
                            Menu {
                                Picker(selection: $sortingArgument.animation()) {
                                    Text("Shooting date ↑").tag(PhotosSortArgument.creationDateDesc)
                                    Text("Shooting date ↓").tag(PhotosSortArgument.creationDateAsc)
                                    Text("Importing date ↑").tag(PhotosSortArgument.importDateDesc)
                                    Text("Importing date ↓").tag(PhotosSortArgument.importDateAsc)
                                } label: {}
                            } label: {
                                Label("Sorting by", systemImage: "arrow.up.arrow.down")
                            }

                            Divider()

                            if currentAlbum != nil {
                                Button(role: .destructive) {
                                    isPresentingDeleteAlbum.toggle()
                                } label: {
                                    Label("Delete album", systemImage: "trash")
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
                if selectingMode {
                    ToolbarItemGroup(placement: .bottomBar) {
                        if photosSelector == .deleted {
                            Button { isPresentingDeletePhotos.toggle() } label: { Text("Delete") }
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
                            Button { isPresentingDeletePhotos.toggle() } label: {
                                Image(systemName: "trash")
                            }
                            .disabled(selectedImagesArray.count == 0)
                            Menu {
                                if currentAlbum != nil, currentAlbum?.filterOptionsSet == nil {
                                    Button {
                                        withAnimation {
                                            selectedImagesArray.forEach { img in
                                                if let uuid = img.uuid, let set = JSONToSet(currentAlbum?.photosSet) {
                                                    var currentSet = set
                                                    currentSet.remove(uuid.uuidString)
                                                    currentAlbum?.photosSet = setToJSON(currentSet)!
                                                }
                                            }
                                        }
                                        do {
                                            try viewContext.save()
                                            sceneSettings.isShowingTabBar = true
                                            selectingMode.toggle()
                                            selectedImagesArray = []
                                        } catch {
                                            sceneSettings.errorAlertData = error.localizedDescription
                                            sceneSettings.isShowingErrorAlert.toggle()
                                        }
                                    } label: {
                                        Label("Remove from album", systemImage: "rectangle.stack.badge.minus")
                                    }
                                }

                                Button {
                                    isPresentingAddToAlbum.toggle()
                                } label: {
                                    Label("Add to album", systemImage: "rectangle.stack.badge.plus")
                                }

                                Divider()

                                Button {
                                    isPresentingEditTags.toggle()
                                } label: {
                                    Label("Edit keywords", systemImage: "text.word.spacing")
                                }

                            } label: {
                                Image(systemName: "ellipsis.circle")
                            }
                            .disabled(selectedImagesArray.count == 0)
                        }
                    }
                }
            }

            .sheet(isPresented: $isPresentingAddToAlbum) {
                AddToAlbumView(photos: photos, albums: albums, miniatures: miniatures, isPresentingAddToAlbum: $isPresentingAddToAlbum,
                               selectingMode: $selectingMode, selectedImagesArray: $selectedImagesArray)
            }
            .sheet(isPresented: $isPresentingEditTags, onDismiss: {
                if isPhotosChanged {
                    selectedImagesArray = []
                    selectingMode = false
                    isPhotosChanged = false
                    sceneSettings.isShowingTabBar.toggle()
                }
            }, content: {
                if selectedImagesArray.count > 0 {
                    EditTagsView(selectedImages: selectedImagesArray.map { $0.uuid! },
                                 photos: photos, library: library, isChanged: $isPhotosChanged)
                }
            })
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
                library.toBin(selectedImagesArray, in: viewContext) { err in
                    if let err {
                        sceneSettings.errorAlertData = err.localizedDescription
                        sceneSettings.isShowingErrorAlert.toggle()
                    }
                }
            case .recover:
                library.recoverImages(selectedImagesArray, in: viewContext) { err in
                    if let err {
                        sceneSettings.errorAlertData = err.localizedDescription
                        sceneSettings.isShowingErrorAlert.toggle()
                    }
                }
            case .permanent:
                library.permanentRemove(selectedImagesArray, in: viewContext) { err in
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
        print("Started importing...")
        Task {
            sceneSettings.infoBarData = "Importing..."; sceneSettings.infoBarFinal = false
            let importCount = importSelectedItems.count
            withAnimation { sceneSettings.isShowingInfoBar.toggle() }
            var count = 0
            var cloudRecords = [CKRecord]()
            let photosAssets = NSMutableArray()
            var lastUUID: UUID?
            for item in importSelectedItems {
                withAnimation { sceneSettings.infoBarProgress = Double(count) / Double(importSelectedItems.count) }

                if let data = try? await item.loadTransferable(type: Data.self) {
                    let uiImage = UIImage(data: data)
                    if let uiImage {
                        let creationDate: Date
                        if let localID = item.itemIdentifier {
                            let asset = PHAsset.fetchAssets(withLocalIdentifiers: [localID], options: nil).firstObject
                            if let asset {
                                creationDate = asset.creationDate ?? Date()
                                photosAssets.add(asset)
                            } else {
                                creationDate = Date()
                            }
                        } else { creationDate = Date() }

                        let fileExtension: String = item.supportedContentTypes.first?.preferredFilenameExtension ?? "heic"
                        let uuid = UUID()
                        let data = generateMiniatureData(uiImage)

                        if writeImageToFile(uuid, uiImage: uiImage, fileExtension: fileExtension, library: library.uuid) {
                            let newPhoto = Photo(context: viewContext)
                            newPhoto.uuid = uuid
                            newPhoto.libraryID = library.uuid
                            newPhoto.status = PhotoStatus.normal.rawValue
                            newPhoto.creationDate = creationDate
                            newPhoto.importDate = Date()
                            newPhoto.deletionDate = nil
                            newPhoto.fileExtension = fileExtension
                            library.photosIDs.append(uuid)

                            let newMiniature = Miniature(context: viewContext)
                            newMiniature.uuid = uuid
                            newMiniature.miniature = data

                            let imageAsset = CKAsset(fileURL: imageFileURL(uuid,
                                                    fileExtension: fileExtension, libraryID: library.uuid))

                            let photoCloudRecord = CKRecord(recordType: "FullSizePhotos")
                            photoCloudRecord["library"] = library.uuid.uuidString as CKRecordValue
                            photoCloudRecord["photo"] = uuid.uuidString as CKRecordValue
                            photoCloudRecord["asset"] = imageAsset
                            newPhoto.fullsizeCloudID = photoCloudRecord.recordID.recordName
                            syncArr.append(uuid)
                            cloudRecords.append(photoCloudRecord)

                            //                            do {
                            //                                try viewContext.save()
                            //                            } catch {
                            //                                sceneSettings.errorAlertData = error.localizedDescription
                            //                                sceneSettings.isShowingErrorAlert.toggle()
                            //                            }
                        }
                        lastUUID = uuid
                        count+=1
                    }
                }
            }

            do {
                library.lastChange = Date()
                try viewContext.save()
                try PHPhotoLibrary.shared().performChangesAndWait {
                    PHAssetChangeRequest.deleteAssets(photosAssets)
                }
            } catch {
                if (error as NSError).code != 3072 {
                    sceneSettings.errorAlertData = error.localizedDescription
                    sceneSettings.isShowingErrorAlert.toggle()
                }
            }

            withAnimation {
                scrollTo = lastUUID
                sceneSettings.infoBarFinal = true; sceneSettings.infoBarData = "\(count) photos saved"
                sceneSettings.infoBarProgress = Double(count) / Double(importCount)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation { sceneSettings.isShowingInfoBar.toggle() }
                }
            }

            importSelectedItems = []
            uploadPhotos(cloudRecords)
        }
    }
    private func uploadPhotos(_ records: [CKRecord]) {
        for item in records {
            do {
                cloudDatabase.save(item) { record, error in
                    if let error {
                        debugPrint(error)
                    } else {
                        if let index = syncArr.firstIndex(
                            where: { $0.uuidString == record?.value(forKey: "photo") as? String}
                        ) {
                            syncArr.remove(at: index)
                        }
                    }
                }
            }
        }
    }
}

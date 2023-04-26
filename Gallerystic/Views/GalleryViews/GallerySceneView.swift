//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI
import PhotosUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct GallerySceneView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dispayingSettings: DispayingSettings
    
    @ObservedObject var library: PhotosLibrary
    @State var photosSelector: PhotoStatus
    
    @State var isMainLibraryScreen: Bool = false
    @Binding var sortingSelector: PhotosSortArgument
    @Binding var uiImageHolder: UIImageHolder
    @State private var importSelectedItems = [PhotosPickerItem]()
    
    @State var showGalleryOverlay: Bool = false
    @State var selectedImage: Photo?
    
    @State var selectingMode: Bool = false
    @State var selectedImagesArray: [Photo] = []
    
    @State var isPresentingConfirm: Bool = false
    @State var scrollTo: UUID?
    @Binding var navToRoot: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                if library.photos.filter({ ph in
                    ph.status == photosSelector
                }).count > 0 {
                    UIGalleryView(library: library, photosSelector: photosSelector, sortingSelector: $sortingSelector, uiImageHolder: $uiImageHolder, scrollTo: $scrollTo, selectingMode: $selectingMode, selectedImagesArray: $selectedImagesArray, isMainLibraryScreen: isMainLibraryScreen)
                } else {
                    Text(Int.random(in: 1...100) == 7 ? "These aren't the photos you're looking for." : "No photos or videos here").font(.title2).bold()
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
                ToolbarItemGroup (placement: .navigationBarTrailing) {
                    Button {
                        selectingMode.toggle()
                        if selectingMode {
                            dispayingSettings.isShowingTabBar = false
                        } else {
                            dispayingSettings.isShowingTabBar = true
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
                            Text(selectedImagesArray.count > 0 ? "\(selectedImagesArray.count) selected" : "Select photos").bold()
                            Spacer()
                            Button { changePhotoStatus(to: .recover) } label: { Text("Recover") }
                                .disabled(selectedImagesArray.count==0)
                        } else {
                            Spacer()
                            Text(selectedImagesArray.count > 0 ? "\(selectedImagesArray.count) selected" : "Select photos").bold()
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
            
            if isMainLibraryScreen {
                synchronizeLibrary()
            }
        }
        .onDisappear {
            if selectingMode {
                dispayingSettings.isShowingTabBar = true
                selectingMode.toggle()
                selectedImagesArray = []
            }
        }
        
        .onChange(of: navToRoot) { _ in
            dismiss()
            navToRoot = false
        }
    }
    
    private func changePhotoStatus(to: RemovingDirection) {
        withAnimation {
            switch to {
            case .bin:
                library.toBin(selectedImagesArray) { err in
                    if let err {
                        dispayingSettings.errorAlertData = err.localizedDescription
                        dispayingSettings.isShowingErrorAlert.toggle()
                    }
                }
            case .recover:
                library.recoverImages(selectedImagesArray) { err in
                    if let err {
                        dispayingSettings.errorAlertData = err.localizedDescription
                        dispayingSettings.isShowingErrorAlert.toggle()
                    }
                }
            case .permanent:
                library.permanentRemove(selectedImagesArray) { err in
                    if let err {
                        dispayingSettings.errorAlertData = err.localizedDescription
                        dispayingSettings.isShowingErrorAlert.toggle()
                    }
                }
            }
        }
        
        dispayingSettings.isShowingTabBar = true
        selectingMode.toggle()
        selectedImagesArray = []
    }
    private func importFromPhotosApp() {
        Task {
            dispayingSettings.infoBarData = "Importing..."
            dispayingSettings.infoBarFinal = false
            let importCount = importSelectedItems.count
            withAnimation { dispayingSettings.isShowingInfoBar.toggle() }
            var count = 0
            var newPhotos: [Photo] = []
            for item in importSelectedItems {
                withAnimation {
                    dispayingSettings.infoBarProgress = Double(count) / Double(importSelectedItems.count)
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
                        
                        let fileExtention: PhotoExtention
                        if let format = item.supportedContentTypes.first?.identifier, format == "public.png" {
                            fileExtention = .png
                        } else {
                            fileExtention = .jpg
                        }
                        
                        let uuid = writeImageToFile(uiImage: uiImage)
                        if let uuid {
                            newPhotos.append(Photo(id: uuid, status: .normal, creationDate: creationDate, importDate: Date(), fileExtention: fileExtention, keywords: []))
                            count += 1
                        }
                    }
                }
            }
            withAnimation {
                library.addImages(newPhotos) { finalCount, err in
                    if let err {
                        dispayingSettings.errorAlertData = err.localizedDescription
                        dispayingSettings.isShowingErrorAlert.toggle()
                    } else {
                        scrollTo = newPhotos.last?.id
                        dispayingSettings.infoBarFinal = true
                        dispayingSettings.infoBarData = "\(finalCount) photos saved"
                        dispayingSettings.infoBarProgress = Double(finalCount) / Double(importCount)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation { dispayingSettings.isShowingInfoBar.toggle() }
                        }
                    }
                }
                newPhotos.forEach { ph in
                    OnlineFunctions.uploadImage(photo: ph) { task, taskFull, error in
                        if let error {
                            dispayingSettings.errorAlertData = error.localizedDescription
                            dispayingSettings.isShowingErrorAlert.toggle()
                        } else {
                            task?.observe(.progress, handler: { snapshot in
                                let progress = snapshot.progress!
                                withAnimation {
                                    dispayingSettings.syncProgress = Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                                }
                            })
                            task?.observe(.success, handler: { _ in
                                taskFull?.observe(.progress, handler: { snapshot in
                                    let progress = snapshot.progress!
                                    withAnimation {
                                        dispayingSettings.syncProgress = Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                                    }
                                })
                            })
                        }
                    }
                }
            }
            importSelectedItems = []
        }
    }
    private func synchronizeLibrary() {
        OnlineFunctions.getSyncData(lib: library, competition: { toUpload, toDownload, error in
            if let error {
                dispayingSettings.errorAlertData = error.localizedDescription
                dispayingSettings.isShowingErrorAlert.toggle()
            } else {
                
                if toUpload.count == 0 && toDownload.count == 0 {
                    dispayingSettings.syncProgress = 1
                } else {
                    
                    // Adding data to online library and uploading
                    if toUpload.count > 0 {
                        OnlineFunctions.addPhotos(toUpload, lib: library) { error in
                            if let error {
                                dispayingSettings.errorAlertData = error.localizedDescription
                                dispayingSettings.isShowingErrorAlert.toggle()
                            } else {
                                toUpload.forEach { ph in
                                    OnlineFunctions.uploadImage(photo: ph) { task, taskFull, error in
                                        if let error {
                                            dispayingSettings.errorAlertData = error.localizedDescription
                                            dispayingSettings.isShowingErrorAlert.toggle()
                                        } else {
                                            task?.observe(.progress, handler: { snapshot in
                                                let progress = snapshot.progress!
                                                withAnimation {
                                                    dispayingSettings.syncProgress = Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                                                }
                                            })
                                            task?.observe(.success, handler: { _ in
                                                taskFull?.observe(.progress, handler: { snapshot in
                                                    let progress = snapshot.progress!
                                                    withAnimation {
                                                        dispayingSettings.syncProgress = Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                                                    }
                                                })
                                            })
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Adding data to local library and downloading
                    if toDownload.count > 0 {
                        toDownload.forEach { ph in
                            OnlineFunctions.downloadImage(id: ph.id, fullSize: false) { task, error in
                                if let error {
                                    dispayingSettings.errorAlertData = error.localizedDescription
                                    dispayingSettings.isShowingErrorAlert.toggle()
                                } else {
                                    
                                    library.addImages([ph]) { _, error in
                                        if let error {
                                            dispayingSettings.errorAlertData = error.localizedDescription
                                            dispayingSettings.isShowingErrorAlert.toggle()
                                        }
                                    }
                                    
                                    task?.observe(.progress, handler: { snapshot in
                                        let progress = snapshot.progress!
                                        withAnimation {
                                            dispayingSettings.syncProgress = Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                                        }
                                    })
                                }
                            }
                        }
                    }
                }
            }
        })
    }
}

//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI
import PhotosUI

struct GallerySceneView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dispayingSettings: DispayingSettings
    
    @ObservedObject var library: PhotosLibrary
    @State var photosSelector: PhotoStatus
    
    @State var canAddNewPhotos: Bool = false
    @Binding var sortingSelector: PhotosSortArgument
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
                    GalleryView(library: library, photosSelector: photosSelector, sortingSelector: $sortingSelector, scrollTo: $scrollTo, selectingMode: $selectingMode, selectedImagesArray: $selectedImagesArray)
                } else {
                    Text(Int.random(in: 1...100) == 7 ? "These aren't the photos you're looking for." : "No photos or videos here").font(.title2).bold()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
//            .navigationBarTitle(selectingMode ? "\(selectedImagesArray.count) selected" : "")
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
                if canAddNewPhotos, !selectingMode {
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
                                Task {
                                    dispayingSettings.infoBarData = "Importing..."
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
                                                
                                                let uuid = writeImageToFile(uiImage: uiImage, fileExtention: fileExtention.rawValue)
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
                                                withAnimation {
                                                    dispayingSettings.infoBarData = "\(finalCount) photos saved"
                                                    dispayingSettings.infoBarProgress = Double(finalCount) / Double(importSelectedItems.count)
                                                }
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                                    withAnimation { dispayingSettings.isShowingInfoBar.toggle() }
                                                }
                                            }
                                        }
                                    }
                                    importSelectedItems = []
                                }
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
}

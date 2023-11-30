//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI

struct ImageDetailedView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var sceneSettings: SceneSettings

    @StateObject var library: PhotosLibrary
    var photos: [Photo]
    var photosResult: FetchedResults<Photo>
    var albums: FetchedResults<Album>
    var miniatures: FetchedResults<Miniature>

    @Binding var photosSelector: PhotoStatus
    @Binding var selectedImage: UUID?
    @State var scrollTo: UUID?
    @State var isPresentingConfirm: Bool = false
    @State var isPresentingAddToAlbum: Bool = false
    @State var isPresentingEditTags: Bool = false

    @State var tempFullsizeImages: [UUID: UIImage] = [:]

    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    TabView(selection: $selectedImage) {
                        ForEach(photos, id: \.uuid) { item in
                            VStack {
                                if let uuid = item.uuid, 
                                    let miniature = miniatures
                                    .first(where: { $0.uuid == uuid })?.miniature {
                                    if item.uuid == selectedImage! {
                                        if fileExistsAtPath(imageFileURL(uuid, fileExtension: item.fileExtension!, libraryID: item.libraryID).path) ||
                                            fileExistsAtPath(imageFileURL(uuid, fileExtension: "heic", libraryID: item.libraryID).path) {
                                            Image(uiImage: readImageFromFile(item) ?? UIImage(data: miniature) ??
                                                  UIImage(systemName: "photo.on.rectangle.angled")!)
                                            .resizable()
                                            .scaledToFit()
                                            .pinchToZoom()
                                        } else if let uiImage = tempFullsizeImages[uuid] {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFit()
                                                .pinchToZoom()
                                        } else {
                                            Image(uiImage: UIImage(data: miniature) ??
                                                  UIImage(systemName: "photo.on.rectangle.angled")!)
                                            .resizable()
                                            .scaledToFit()
                                            .onAppear {
                                                getCloudImage(item) { uiImage, err in
                                                    if let err {
                                                        sceneSettings.errorAlertData = err.localizedDescription
                                                        sceneSettings.isShowingErrorAlert.toggle()
                                                    } else if let uiImage {
                                                        tempFullsizeImages.updateValue(uiImage, forKey: uuid)
                                                    }
                                                }
                                            }
                                        }
                                    } else {
                                        Image(uiImage: UIImage(data: miniature) ??
                                              UIImage(systemName: "photo.on.rectangle.angled")!)
                                        .resizable()
                                        .scaledToFit()
                                    }
                                }
                            }
                            .frame(maxHeight: .infinity)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .padding(.vertical, 10)
                }

                if sceneSettings.isShowBottomScroll {
                    ScrollViewReader { scroll in
                        ScrollView(.horizontal) {
                            LazyHStack(spacing: 2) {
                                ForEach(photos, id: \.uuid) { item in
                                    if let uuid = item.uuid {
                                        if let data = miniatures.first(where: {$0.uuid == uuid})?.miniature, let uiImage = UIImage(data: data) {
                                            Button {
                                                self.selectedImage = uuid
                                                scrollTo = selectedImage
                                            } label: {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 75, height: 75, alignment: .center)
                                                    .clipped()
                                                    .id(item.uuid)
                                                    .overlay {
                                                        if selectedImage == item.uuid {
                                                            ZStack {
                                                                Color.black.opacity(0.7)
                                                                Image(systemName: "arrow.up.square")
                                                                    .foregroundColor(.white)
                                                                    .font(.title)
                                                            }
                                                        }
                                                    }
                                            }
                                        }
                                    }
                                }
                            }
                            .frame(height: 80)
                            .onAppear {
                                scroll.scrollTo(selectedImage, anchor: .center)
                            }
                            .onChange(of: selectedImage) { _ in
                                scroll.scrollTo(selectedImage, anchor: .center)
                            }
                        }
                    }
                }
            }
            .toolbar {

                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.backward")
                        }
                        Spacer()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
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

                }

                ToolbarItemGroup(placement: .bottomBar) {
                    if photosSelector == .deleted {
                        Button { isPresentingConfirm.toggle() } label: { Text("Delete") }
                    }

                    Spacer()

                    Button {
                        withAnimation {
                            sceneSettings.isShowBottomScroll.toggle()
                        }
                    } label: {
                        ZStack {
                            if sceneSettings.isShowBottomScroll {
                                Color.accentColor
                                    .cornerRadius(5)
                            }
                            Image(systemName: "rectangle.bottomhalf.inset.filled")
                                .foregroundColor(sceneSettings.isShowBottomScroll ? .white : .accentColor)
                        }
                    }

                    Spacer()

                    if photosSelector == .deleted {
                        Button { changePhotoStatus(to: .recover) } label: { Text("Recover") }
                    } else {
                        Button { isPresentingConfirm.toggle() } label: { Image(systemName: "trash") }
                    }
                }
            }
            .padding(.vertical, 10)
            .sheet(isPresented: $isPresentingAddToAlbum) {
                AddToAlbumView(photos: photosResult, albums: albums, miniatures: miniatures,
                               isPresentingAddToAlbum: $isPresentingAddToAlbum, selectingMode: .constant(true),
                               selectedImagesArray: .constant([]), selectedImage: selectedImage)
            }
            .sheet(isPresented: $isPresentingEditTags, content: {
                if let selectedImage {
                    EditTagsView(selectedImages: [selectedImage], photos: photosResult, library: library, isChanged: .constant(false))
                }
            })
            .confirmationDialog("Delete this photo", isPresented: $isPresentingConfirm) {
                Button("Delete photo", role: .destructive) {
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
        }
    }


    private func changePhotoStatus(to destination: RemovingDirection) {
        let changedPhoto = photos.first(where: { $0.uuid == selectedImage })
        if let changedPhoto, let photoIndex = photos.firstIndex(of: changedPhoto) {
            switch destination {
            case .bin:
                library.toBin([changedPhoto], in: viewContext) { err in
                    if let err {
                        sceneSettings.errorAlertData = err.localizedDescription
                        sceneSettings.isShowingErrorAlert.toggle()
                    }
                }
            case .recover:
                library.recoverImages([changedPhoto], in: viewContext) { err in
                    if let err {
                        sceneSettings.errorAlertData = err.localizedDescription
                        sceneSettings.isShowingErrorAlert.toggle()
                    }
                }
            case .permanent:
                library.permanentRemove([changedPhoto], in: viewContext) { err in
                    if let err {
                        sceneSettings.errorAlertData = err.localizedDescription
                        sceneSettings.isShowingErrorAlert.toggle()
                    }
                }
            }

            let clearedPhotos = photos.filter { photo in
                photo.status == photosSelector.rawValue
            }

            if clearedPhotos.count == 0 {
                DispatchQueue.main.async {
                    dismiss()
                }
            } else if photoIndex == clearedPhotos.count {
                selectedImage = clearedPhotos[photoIndex - 1].uuid!
            } else {
                selectedImage = clearedPhotos[photoIndex].uuid!
            }
        }
    }
}

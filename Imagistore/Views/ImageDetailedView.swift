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

    @Binding var photosSelector: PhotoStatus
    @StateObject var imageHolder: UIImageHolder

    @Binding var selectedImage: UUID?
    @State var scrollTo: UUID?
    @State var isPresentingConfirm: Bool = false
    @State var isPresentingAddToAlbum: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    TabView(selection: $selectedImage) {
                        ForEach(photos, id: \.uuid) { item in
                            VStack {
                                if let uuid = item.uuid {
                                    if selectedImage == item.uuid, let fullUiImage = readImageFromFile(item) {
                                        Image(uiImage: fullUiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .pinchToZoom()

                                    }
                                    else if let uiImage = imageHolder.data[uuid] {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .pinchToZoom()
                                            .task {
                                                await imageHolder.loadFullImage(item)
                                            }
                                    }
                                }
                            }
                            .frame(maxHeight: .infinity)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .padding(.vertical, 10)
                }

                // Disabled by slow animations
                ScrollViewReader { scroll in
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 2) {
                            ForEach(photos, id: \.uuid) { item in
                                if let uuid = item.uuid {
                                    if let uiImage = imageHolder.data[uuid] {
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
                            withAnimation {
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
                            HStack {
                                Image(systemName: "chevron.backward")
                                Text("Back")
                            }
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
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }

                }

                ToolbarItemGroup(placement: .bottomBar) {
                    if photosSelector == .deleted {
                        Button { isPresentingConfirm.toggle() } label: { Text("Delete permanently") }
                        Button { changePhotoStatus(to: .recover) } label: { Text("Recover") }
                    } else {
                        Button { isPresentingConfirm.toggle() } label: { Image(systemName: "trash") }
                    }
                }
            }
            .padding(.vertical, 10)
            .foregroundColor(.blue)

            .sheet(isPresented: $isPresentingAddToAlbum) {
                AddToAlbumView(photos: photosResult, albums: albums,
                               isPresentingAddToAlbum: $isPresentingAddToAlbum, selectingMode: .constant(true),
                               imageHolder: imageHolder, selectedImagesArray: .constant([]), selectedImage: selectedImage)
            }
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

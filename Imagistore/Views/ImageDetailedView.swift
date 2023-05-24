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

    @Binding var photosSelector: PhotoStatus
    @StateObject var imageHolder: UIImageHolder

    @Binding var selectedImage: UUID?
    @State var scrollTo: UUID?
    @State var isPresentingConfirm: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                    Spacer()
                    if let img = photos.first(where: {$0.uuid == selectedImage}), img.fileExtension == "png" {
                        Text("PNG")
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                }
                .font(.title2)
                .padding(.horizontal, 10)
                .padding(.top, 10)

                VStack {
                    TabView(selection: $selectedImage) {
                        ForEach(photos, id: \.uuid) { item in
                            VStack {
                                if let uuid = item.uuid {
                                    if let uiImage = imageHolder.fullUiImage(uuid) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .pinchToZoom()
                                            .task { checkFileRecord(item) }
                                    } else if let uiImage = imageHolder.data[uuid] {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .overlay(alignment: .bottomTrailing, content: {
                                                Image(systemName: "circle.dashed")
                                                    .font(.title)
                                                    .padding(10)
                                                    .foregroundColor(.gray)
                                            })
                                            .task {
                                                await imageHolder.getFullUiImage(item) { err in
                                                    if let err {
                                                        sceneSettings.errorAlertData = err.localizedDescription
                                                        sceneSettings.isShowingErrorAlert.toggle()
                                                    }
                                                }
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
                                            if selectedImage == item.uuid {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(maxHeight: 75, alignment: .center)
                                                    .padding(5)
                                                    .border(Color.gray, width: 4)
                                                    .padding(.horizontal, 20)
                                                    .clipped()
                                                    .id(item.uuid)
                                            } else {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 50, height: 75, alignment: .center)
                                                    .clipped()
                                                    .id(item.uuid)
                                            }
                                        }
                                    } else {
                                        Rectangle()
                                            .fill(Color.gray)
                                            .task {
                                                if let uuid = item.uuid,
                                                   let data = item.miniature, let uiImage = UIImage(data: data) {
                                                    imageHolder.data[uuid] = uiImage
                                                    imageHolder.objectWillChange.send()
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
                library.permanentRemove([changedPhoto], library: library, in: viewContext) { err in
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

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
//    var filteredPhotos: [Photo] {
//        sortedPhotos(photos, by: sortingArgument, filter: photosSelector)
//    }

    @Binding var photosSelector: PhotoStatus
//    @Binding var sortingSelector: PhotosSortArgument
    @StateObject var imageHolder: UIImageHolder

    @Binding var selectedImage: UUID
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
                    if let photo = photos.first(where: {$0.uuid == selectedImage}), photo.fileExtension == "png" {
                        Text("PNG")
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                }
                .font(.title2)
                .padding(.leading, 10)
                .padding(.top, 10)

                VStack {
                    TabView(selection: $selectedImage) {
                        ForEach(photos, id: \.uuid) { item in
                            VStack {
                                if let uiImage = imageHolder.data[item.uuid] {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .pinchToZoom()
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
                            ForEach(photos) { item in
                                if let uiImage = imageHolder.data[item.uuid] {
                                    Button {
                                        self.selectedImage = item.uuid
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
                                    //                            } else if !imageHolder.notFound.contains(item.id) {
                                    //                                Rectangle()
                                    //                                    .fill(Color.gray)
                                    //                                    .task {
                                    //                                        await imageHolder.getUiImage(item, lib: library)
                                    //                                    }
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
                //            HStack {
                //                if photosSelector == .deleted {
                //                    Button {
                ////                        isPresentingConfirm.toggle()
                //                    } label: {
                //                        Text("Delete permanently")
                //                    }
                //                    Spacer()
                //                    Button {
                ////                        changePhotoStatus(to: .recover)
                //                    } label: {
                //                        Text("Recover")
                //                    }
                //                } else {
                //                    Button {
                //                        isPresentingConfirm.toggle()
                //                    } label: {
                //                        Image(systemName: "trash")
                //                            .font(.title2)
                //                    }
                //                }
                //            }
                //            .padding(.vertical, 10)
                //            .foregroundColor(.blue)
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
                print("HEHE")
//                library.permanentRemove([changedPhoto], library: library) { err in
//                    if let err {
//                        sceneSettings.errorAlertData = err.localizedDescription
//                        sceneSettings.isShowingErrorAlert.toggle()
//                    }
//                }
            }

            let clearedPhotos = photos.filter { photo in
                photo.status == photosSelector.rawValue
            }

            if clearedPhotos.count == 0 {
                DispatchQueue.main.async {
                    dismiss()
                }
            } else if photoIndex == clearedPhotos.count {
                selectedImage = clearedPhotos[photoIndex - 1].uuid
            } else {
                selectedImage = clearedPhotos[photoIndex].uuid
            }
        }
    }
}

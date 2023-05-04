//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI

struct ImageDetailedView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var sceneSettings: SceneSettings

    @ObservedObject var library: PhotosLibrary
    var photos: [Photo] { library.sortedPhotos(by: sortingSelector, filter: photosSelector) }

    @State var photosSelector: PhotoStatus
    @Binding var sortingSelector: PhotosSortArgument
    @Binding var uiImageHolder: UIImageHolder

    @State var selectedImage: UUID
    @Binding var scrollTo: UUID?
    @State var isPresentingConfirm: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                TabView(selection: $selectedImage) {
                    ForEach(photos) { item in
                        if let uiImage = uiImageHolder.getFullUiImage(photo: item) {
                            ZStack {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .pinchToZoom()
                            }
                            .frame(maxHeight: .infinity)
                            .overlay(alignment: .bottomTrailing) {
                                if item.fileExtension == .png {
                                    Text("PNG")
                                        .foregroundColor(.none)
                                        .padding(.horizontal, 10)
                                        .background(Color(UIColor.lightGray))
                                        .cornerRadius(10)
                                        .padding(.horizontal, 10)
                                }
                            }
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .padding(.vertical, 10)
            }

            ScrollViewReader { scroll in
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 2) {
                        ForEach(photos) { item in
                            if let uiImage = uiImageHolder.getUiImage(photo: item) {
                                Button {
                                    self.selectedImage = item.id
                                    scrollTo = selectedImage
                                } label: {
                                    if selectedImage == item.id {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxHeight: 75, alignment: .center)
                                            .padding(5)
                                            .border(Color.primary, width: 5)
                                            .padding(.horizontal, 20)
                                            .clipped()
                                            .id(item.id)
                                    } else {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 75, alignment: .center)
                                            .clipped()
                                            .id(item.id)
                                    }
                                }
                            }
                        }
                    }
                    .frame(height: 80)
                    .onAppear { scroll.scrollTo(selectedImage, anchor: .center) }
                    .onChange(of: selectedImage) { _ in
                        withAnimation { scroll.scrollTo(selectedImage, anchor: .center) }
                    }
                }
            }
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

        .onAppear { sceneSettings.isShowingTabBar = false }
        .onDisappear { sceneSettings.isShowingTabBar = true }

        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
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
    }

    private func changePhotoStatus(to destination: RemovingDirection) {
        let changedPhoto = photos.first(where: { $0.id == selectedImage })
        if let changedPhoto, let photoIndex = photos.firstIndex(of: changedPhoto) {
            switch destination {
            case .bin:
                library.toBin([changedPhoto]) { err in
                    if let err {
                        sceneSettings.errorAlertData = err.localizedDescription
                        sceneSettings.isShowingErrorAlert.toggle()
                    }
                }
            case .recover:
                library.recoverImages([changedPhoto]) { err in
                    if let err {
                        sceneSettings.errorAlertData = err.localizedDescription
                        sceneSettings.isShowingErrorAlert.toggle()
                    }
                }
            case .permanent:
                library.permanentRemove([changedPhoto]) { err in
                    if let err {
                        sceneSettings.errorAlertData = err.localizedDescription
                        sceneSettings.isShowingErrorAlert.toggle()
                    }
                }
            }

            if photos.count == 0 {
                DispatchQueue.main.async { dismiss() }
            } else if photoIndex == photos.count {
                selectedImage = photos[photoIndex-1].id
            } else {
                selectedImage = photos[photoIndex].id
            }
        }
    }
}

//
//  Created by Evhen Gruzinov on 14.03.2023.
//

import SwiftUI

struct UIGalleryView: View {
    @EnvironmentObject var sceneSettings: SceneSettings
    @StateObject var library: PhotosLibrary
    var photos: [Photo]

    @State var photosSelector: PhotoStatus
    @Binding var sortingArgument: PhotosSortArgument
    @StateObject var imageHolder: UIImageHolder
    @Binding var scrollTo: UUID?
    @Binding var scrollToBottom: Bool
    @Binding var selectingMode: Bool
    @Binding var selectedImagesArray: [Photo]
    @Binding var syncArr: [UUID]

    @State var openedImage: UUID?
    @State var goToDetailedView: Bool = false
    @State var isMainLibraryScreen: Bool = false

    let columns = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1)
    ]

    var body: some View {
        ScrollViewReader { scroll in
            ScrollView {
                LazyVGrid(columns: columns, alignment: .center, spacing: 1) {
                    ForEach(photos) { item in
                        GeometryReader { geometryReader in
                            let size = geometryReader.size
                            VStack {
                                if let uuid = item.uuid, let uiImage = imageHolder.data[uuid] {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: size.height, height: size.width, alignment: .center)
                                            .id(item.uuid)
                                            .overlay(
                                                ZStack {
                                                    if let deletionDate = item.deletionDate {
                                                        LinearGradient(colors: [.black.opacity(0), .black],
                                                                       startPoint: .center, endPoint: .bottom)
                                                        VStack(alignment: .center) {
                                                            Spacer()
                                                            Text(DateTimeFunctions.daysLeftString(deletionDate))
                                                                .font(.caption)
                                                                .padding(5)
                                                                .foregroundColor(
                                                                    DateTimeFunctions
                                                                        .daysLeft(deletionDate) < 3
                                                                    ? .red : .white)
                                                        }
                                                    }
                                                }
                                            )
                                            .overlay(alignment: .bottomTrailing, content: {
                                                if selectedImagesArray.contains(item) {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .font(.title2)
                                                        .foregroundColor(Color.accentColor)
                                                        .padding(1)
                                                        .background(Circle().fill(.white))
                                                        .padding(5)
                                                }
                                            })
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
                            .onTapGesture {
                                if selectingMode {
                                    if let index = selectedImagesArray.firstIndex(of: item) {
                                        selectedImagesArray.remove(at: index)
                                    } else {
                                        selectedImagesArray.append(item)
                                    }
                                } else {
                                    if let uuid = item.uuid {
                                        openedImage = uuid
                                        goToDetailedView.toggle()
                                    }
                                }
                            }
                        }
                        .clipped()
                        .aspectRatio(1, contentMode: .fit)
                    }
                }
                VStack {
                    if isMainLibraryScreen {
                        Text("\(photos.count) Photos")
                            .font(.callout)
                            .bold()
                        if syncArr.count > 0 {
                            Text("Syncing: \(syncArr.count) photos left")
                                .font(.caption)
                                .foregroundColor(.gray)
                        } else {
                            Text("Synced")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.vertical, 10)

                Rectangle()
                    .frame(height: 50)
                    .opacity(0)
                    .id("bottomRectangle")
            }
            .onAppear { scrollToBottom.toggle() }
            .onChange(of: scrollTo) { _ in
                if let scrollTo {
                    if sortingArgument == .importDate {
                        scroll.scrollTo("bottomRectangle", anchor: .bottom)
                    } else {
                        scroll.scrollTo(scrollTo, anchor: .center)
                    }
                }
            }
            .onChange(of: openedImage) { _ in
                scroll.scrollTo(openedImage, anchor: .center)
            }
            .onChange(of: scrollToBottom) { _ in
                if scrollToBottom {
                    scroll.scrollTo("bottomRectangle", anchor: .bottom)
                    scrollToBottom.toggle()
                }
            }
            .fullScreenCover(isPresented: $goToDetailedView) {
                ImageDetailedView(library: library, photos: photos,
                        photosSelector: $photosSelector, imageHolder: imageHolder, selectedImage: $openedImage)
            }
        }
    }
}

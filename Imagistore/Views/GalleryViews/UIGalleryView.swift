//
//  Created by Evhen Gruzinov on 14.03.2023.
//

import SwiftUI

struct UIGalleryView: View {
    @EnvironmentObject var sceneSettings: SceneSettings
    @StateObject var library: PhotosLibrary
    var photos: [Photo] { library.sortedPhotos(by: sortingSelector, filter: photosSelector) }

    @State var photosSelector: PhotoStatus
    @Binding var sortingSelector: PhotosSortArgument
    @StateObject var uiImageHolder: UIImageHolder
    @Binding var scrollTo: UUID?
    @Binding var selectingMode: Bool
    @Binding var selectedImagesArray: [Photo]

    @State var openedImage: UUID = UUID()
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

                        GeometryReader { gr in
                            let size = gr.size
                            VStack {
                                if let uiImage = uiImageHolder.data[item.id] {
                                    Button {
                                        if selectingMode {
                                            if let index = selectedImagesArray.firstIndex(of: item) {
                                                selectedImagesArray.remove(at: index)
                                            } else {
                                                selectedImagesArray.append(item)
                                            }
                                        } else {
                                            goToDetailedView.toggle()
                                            openedImage = item.id
                                        }
                                    } label: {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: size.height, height: size.width, alignment: .center)
                                            .id(item.id)
                                            .overlay(
                                                ZStack {
                                                    if let deletionDate = item.deletionDate {
                                                        LinearGradient(colors: [.black.opacity(0), .black], startPoint: .center, endPoint: .bottom)
                                                        VStack(alignment: .center) {
                                                            Spacer()
                                                            Text(DateTimeFunctions.daysLeftString(deletionDate))
                                                                .font(.caption)
                                                                .padding(5)
                                                                .foregroundColor(DateTimeFunctions.daysLeft(deletionDate) < 3 ? .red : .white)
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
                                    }
                                } else {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .frame(width: size.height, height: size.width, alignment: .center)
                                        .task {
                                            await uiImageHolder.getUiImage(item, lib: library)
                                        }
                                }
                            }
                            .navigationDestination(isPresented: $goToDetailedView) {
                                ImageDetailedView(library: library, photosSelector: photosSelector, sortingSelector: $sortingSelector, uiImageHolder: uiImageHolder, selectedImage: openedImage, scrollTo: $scrollTo)
                            }
                        }
                        .clipped()
                        .aspectRatio(1, contentMode: .fit)
                    }
                }
                VStack {
                    if isMainLibraryScreen {
                        Text("\(photos.count) Photos").bold()
                    }
                }
                .padding(.vertical, 10)

                Rectangle()
                    .frame(height: 50)
                    .opacity(0)
                    .id("bottomRectangle")
            }
            .onChange(of: scrollTo) { _ in
                if let scrollTo {
                    if sortingSelector == .importDate {
                        scroll.scrollTo("bottomRectangle", anchor: .bottom)
                    } else {
                        scroll.scrollTo(scrollTo, anchor: .center)
                    }
                }
            }
        }
    }
}

//
//  Created by Evhen Gruzinov on 14.03.2023.
//

import SwiftUI

struct UIGalleryView: View {
    @EnvironmentObject var sceneSettings: SceneSettings
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var library: PhotosLibrary
    var photos: FetchedResults<Photo>
    var albums: FetchedResults<Album>
    @State var currentAlbum: Album?
    @State var photosSelector: PhotoStatus
    @Binding var sortingArgument: PhotosSortArgument
    @Binding var scrollTo: UUID?
    @Binding var selectingMode: Bool
    @Binding var selectedImagesArray: [Photo]
    @Binding var syncArr: [UUID]

    @State var openedImage: UUID?
    @State var goToDetailedView: Bool = false
    @State var isMainLibraryScreen: Bool = false

    var filteredPhotos: [Photo] {
        var filteredPhotos = sortedPhotos(photos, by: sortingArgument, filter: photosSelector)
        if let currentAlbum {
            if let filterOptions = currentAlbum.filterOptions, let filterMode = currentAlbum.filterMode {
                filteredPhotos = filteredPhotos.filter { photo in
                    var matchFilters = true
                    for option in filterOptions {
                        if let type = option["type"] as? String, type == "tagFilter" {
                            if let keyword = option["filterBy"] as? String, let logicalNot = option["logicalNot"] as? Bool {
                                if logicalNot {
//                                    if let keys = photo.keywords, keys.count > 0 {
//                                        return false
//                                    }

                                    if let photoKeywords = photo.keywords, photoKeywords.contains(keyword) {
                                        matchFilters = false
                                    } else if filterMode == "OR" {
                                        matchFilters = true
                                        break
                                    }
                                } else {
                                    if let photoKeywords = photo.keywords {
//                                        if photoKeywords.count == 0 {
//                                            print("PROBLEM HERE")
//                                            return true
//                                        }

                                        if !photoKeywords.contains(keyword) {
                                            matchFilters = false
                                        } else if filterMode == "OR" {
                                            matchFilters = true
                                            break
                                        }
                                    } else { matchFilters = false }
                                }
                            } else {
                                matchFilters = false
                            }
                        }
                    }
                    return matchFilters
                }
            } else {
                filteredPhotos = filteredPhotos.filter { photo in
                    currentAlbum.photos.contains { phId in
                        if let uuid = photo.uuid {
                            return uuid == phId
                        } else {
                            return false
                        }
                    }
                }
            }
        }
        return filteredPhotos
    }

    let columnsPhone = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1)
    ]
    let columnsPad = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1)
    ]

    var body: some View {
        if filteredPhotos.count > 0 {
            ScrollViewReader { scroll in
                ScrollView {
                    Rectangle()
                        .opacity(0)
                        .id("topRectangle")
                    LazyVGrid(columns:
                                UIDevice.current.userInterfaceIdiom == .phone ?
                              columnsPhone : columnsPad, alignment: .center, spacing: 1) {
                        ForEach(filteredPhotos) { item in
                            GeometryReader { geometryReader in
                                let size = geometryReader.size
                                VStack {
                                    if let data = getMiniature(for: item.uuid!, context: viewContext), let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: size.height, height: size.width, alignment: .center)
                                            .clipped()
                                            .contentShape(Path(CGRect(x: 0, y: 0,
                                                    width: size.height, height: size.width)))
                                            .overlay(content: {
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
                                            })
                                            .overlay(alignment: .bottomTrailing, content: {
                                                if selectedImagesArray.contains(item) {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .font(.title2)
                                                        .foregroundColor(Color.accentColor)
                                                        .padding(1)
                                                        .background(Circle().fill(Color("AccentColorOpposite")))
                                                        .padding(5)
                                                }
                                            })
                                            .clipped()
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
                                    .id(item.uuid)
                            .aspectRatio(1, contentMode: .fit)
                        }
                    }
                    Rectangle()
                        .frame(height: 50)
                        .opacity(0)
                        .id("bottomRectangle")
                }
                .onChange(of: scrollTo) { _ in
                    if let scrollTo {
                        if sortingArgument == .importDateDesc {
                            scroll.scrollTo("topRectangle", anchor: .top)
                        } else if sortingArgument == .importDateAsc {
                            scroll.scrollTo("bottomRectangle", anchor: .bottom)
                        } else {
                            scroll.scrollTo(scrollTo, anchor: .center)
                        }
                    }
                }
                .onChange(of: goToDetailedView, perform: { _ in
                    if !goToDetailedView, openedImage != nil {
                        scroll.scrollTo(openedImage)
                    }
                })
                .fullScreenCover(isPresented: $goToDetailedView) {
                    ImageDetailedView(library: library, photos: filteredPhotos, photosResult: photos, albums: albums,
                            photosSelector: $photosSelector, selectedImage: $openedImage)
                }
            }
        } else {
            Text("No photos or videos here").font(.title2).bold()
        }
    }
}

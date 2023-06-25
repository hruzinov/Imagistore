//
//  Created by Evhen Gruzinov on 03.06.2023.
//

import SwiftUI

struct UIAlbumBlockView: View {
    @StateObject var library: PhotosLibrary
    var photos: FetchedResults<Photo>
    var albums: FetchedResults<Album>
    @State var currentAlbum: Album?
    @Binding var sortingArgument: PhotosSortArgument
    @State var photosSelector: PhotoStatus
    @Binding var navToRoot: Bool

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
                                    if let keys = photo.keywords, keys.count > 0 {
                                        return false
                                    }

                                    if let photoKeywords = photo.keywords, photoKeywords.contains(keyword) {
                                        matchFilters = false
                                    } else if filterMode == "OR" {
                                        matchFilters = true
                                        break
                                    }
                                } else {
                                    if let photoKeywords = photo.keywords {
                                        if photoKeywords.count > 0 {
                                            return true
                                        }

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

    var body: some View {
        NavigationLink(destination: {
            GallerySceneView(library: library, photos: photos, albums: albums, currentAlbum: currentAlbum,
                             sortingArgument: $sortingArgument, navToRoot: $navToRoot, photosSelector: photosSelector)
        }, label: {
            HStack {
                if let lastImage = filteredPhotos.last,
                   let data = lastImage.miniature, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width / 2.3,
                                   height: UIScreen.main.bounds.width / 2.3)
                            .clipped()
                            .aspectRatio(1, contentMode: .fit)
                            .cornerRadius(5)
                            .blur(radius: photosSelector == .deleted ? 15 : 0)
                } else {
                    VStack {
                        Spacer()
                        Image(systemName: "photo.on.rectangle")
                            .foregroundColor(.gray)
                            .font(.title)
                        Spacer()
                    }
                    .frame(width: UIScreen.main.bounds.width / 2.3,
                           height: UIScreen.main.bounds.width / 2.3)
                    .background(Color(.init(gray: 0.8, alpha: 1)))
                    .cornerRadius(5)
                }
            }
            .overlay(
                ZStack {
                    LinearGradient(colors: [.black.opacity(0), .black], startPoint: .center, endPoint: .bottom)
                    VStack {
                        Spacer()
                        HStack(alignment: .center) {
                            switch photosSelector {
                            case .normal:
                                if let currentAlbum {
                                    Text(currentAlbum.title)
                                        .padding(5)
                                        .bold()
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(2)
                                    Spacer()
                                    Text(String(filteredPhotos.count))
                                }
                            case .deleted:
                                Text("Deleted photos")
                                    .padding(5)
                                    .bold()
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                                Spacer()
                            }
                        }
                    }
                    .font(.subheadline)
                    .padding(5)
                })
            .cornerRadius(5)
            .foregroundColor(Color.white)

        }).padding(0)
    }
}

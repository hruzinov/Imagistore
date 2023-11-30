//
//  Created by Evhen Gruzinov on 03.06.2023.
//

import SwiftUI

struct UIAlbumBlockView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var library: PhotosLibrary
    var photos: FetchedResults<Photo>
    var albums: FetchedResults<Album>
    var miniatures: FetchedResults<Miniature>
    @State var currentAlbum: Album?
    @Binding var sortingArgument: PhotosSortArgument
    @State var photosSelector: PhotoStatus
    @Binding var navToRoot: Bool

    var filteredPhotos: [Photo] {
        var filteredPhotos = sortedPhotos(photos, by: sortingArgument, filter: photosSelector)
        if let currentAlbum {
            if let filterOptions = JSONToOptions(currentAlbum.filterOptionsSet), let filterMode = currentAlbum.filterMode {
                filteredPhotos = filteredPhotos.filter { photo in
                    var matchFilters = true
                    for option in filterOptions {
                        if let type = option["type"], type == "tagFilter" {
                            if let keyword = option["filterBy"], let logicalNot = option["logicalNot"] {
                                if logicalNot == "true" {
                                    if let keys = JSONToSet(photo.keywordsJSON), keys.count > 0 {
                                        matchFilters = false
                                    }

                                    if let photoKeywords = JSONToSet(photo.keywordsJSON), photoKeywords.contains(keyword) {
                                        matchFilters = false
                                    } else if filterMode == "OR" {
                                        matchFilters = true
                                        break
                                    }
                                } else {
                                    if let photoKeywords = JSONToSet(photo.keywordsJSON) {
                                        if photoKeywords.count > 0 {
                                            matchFilters = true
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
                    JSONToSet(currentAlbum.photosSet)!.contains { phId in
                        if let uuid = photo.uuid {
                            return uuid.uuidString == phId
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
            GallerySceneView(library: library, photos: photos, albums: albums, miniatures: miniatures, currentAlbum: currentAlbum,
                             sortingArgument: $sortingArgument, navToRoot: $navToRoot, photosSelector: photosSelector)
        }, label: {
            HStack {
                if let lastImage = filteredPhotos.last,
                   let data = miniatures.first(where: { $0.uuid == lastImage.uuid!})?.miniature,
                   let uiImage = UIImage(data: data) { 
                    Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width /  ( UIDevice.current.userInterfaceIdiom == .phone ? 2.3 : 3.5),
                                   height: UIScreen.main.bounds.width / ( UIDevice.current.userInterfaceIdiom == .phone ? 2.3 : 3.5))
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
                    .frame(width: UIScreen.main.bounds.width /  ( UIDevice.current.userInterfaceIdiom == .phone ? 2.3 : 3.5),
                           height: UIScreen.main.bounds.width / ( UIDevice.current.userInterfaceIdiom == .phone ? 2.3 : 3.5))
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

//
//  Created by Evhen Gruzinov on 31.03.2023.
//

import SwiftUI
import CoreData

struct AlbumsSceneView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var library: PhotosLibrary
    var photos: FetchedResults<Photo>
    var albums: FetchedResults<Album>
    @Binding var sortingArgument: PhotosSortArgument
    @Binding var navToRoot: Bool
    @StateObject var imageHolder: UIImageHolder

    let rows1 = [
        GridItem(.flexible(minimum: UIScreen.main.bounds.width / 2)),
    ]
    let rows2 = [
        GridItem(.flexible(minimum: UIScreen.main.bounds.width / 2.2)),
        GridItem(.flexible(minimum: UIScreen.main.bounds.width / 2.2))
    ]

    var body: some View {
        NavigationStack {
            VStack {
                if albums.count > 0 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: albums.count > 2 ? rows2 : rows1) {
                            ForEach(albums, id: \.self) { album in
                                UIAlbumBlockViewNew(library: library,
                                                    photos: photos,
                                                    albums: albums,
                                                    currentAlbum: album,
                                                    sortingArgument: $sortingArgument,
                                                    imageHolder: imageHolder, navToRoot: $navToRoot)
                            }
                        }
                    }
                    .padding(.horizontal, 15)
                }

                HStack {
                    Text("Other").font(.title2).bold()
                    Spacer()
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 5)
                VStack(spacing: 10) {
                    Divider()
                    NavigationLink {
                        GallerySceneView(library: library, photos: photos, albums: albums, sortingArgument: $sortingArgument,
                                         imageHolder: imageHolder, navToRoot: $navToRoot, scrollToBottom: .constant(false), photosSelector: .deleted)
                    } label: {
                        HStack {
                            Label("Recently Deleted", systemImage: "trash").font(.title3)
                            Spacer()
                            Text(String(photos.filter({ img in
                                img.status == PhotoStatus.deleted.rawValue
                            }).count)).foregroundColor(Color.secondary)
                            Image(systemName: "chevron.forward").foregroundColor(Color.secondary)
                        }
                        .padding(.horizontal, 15)
                    }
                }
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: NewAlbumSceneView(library: library), label: { Image(systemName: "plus") })
                }
            }
            .navigationTitle("Albums")
        }
    }
}

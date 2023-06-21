//
//  Created by Evhen Gruzinov on 31.03.2023.
//

import SwiftUI
import CoreData
import PhotosUI

struct AlbumsSceneView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var library: PhotosLibrary
    var photos: FetchedResults<Photo>
    var albums: FetchedResults<Album>
    @Binding var sortingArgument: PhotosSortArgument
    @Binding var navToRoot: Bool

    let rows1 = [
        GridItem(.flexible(minimum: UIScreen.main.bounds.width / 2))
    ]
    let rows2 = [
        GridItem(.flexible(minimum: UIScreen.main.bounds.width / 2.2)),
        GridItem(.flexible(minimum: UIScreen.main.bounds.width / 2.2))
    ]

    var body: some View {
        NavigationStack {
            VStack {
                    ScrollView {
                        LazyVGrid(columns: rows2) {
                            ForEach(albums, id: \.self) { album in
                                UIAlbumBlockView(library: library,
                                                    photos: photos,
                                                    albums: albums,
                                                    currentAlbum: album,
                                                    sortingArgument: $sortingArgument,
                                                    photosSelector: .normal,
                                                    navToRoot: $navToRoot)
                            }

                            if photos.filter({ img in
                                img.status == PhotoStatus.deleted.rawValue
                            }).count > 0 {
                                UIAlbumBlockView(library: library,
                                                    photos: photos,
                                                    albums: albums,
                                                    currentAlbum: nil,
                                                    sortingArgument: $sortingArgument,
                                                    photosSelector: .deleted,
                                                    navToRoot: $navToRoot)
                            }
                        }
                    }
                    .padding(.horizontal, 15)
                }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: NewAlbumSceneView(photos: photos, library: library),
                            label: { Image(systemName: "plus") })
                }
            }
            .navigationTitle("Albums")
            }
        }
}

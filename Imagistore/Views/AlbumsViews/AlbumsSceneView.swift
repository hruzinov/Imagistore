//
//  Created by Evhen Gruzinov on 31.03.2023.
//

import SwiftUI

struct AlbumsSceneView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var library: PhotosLibrary
    @Binding var sortingSelector: PhotosSortArgument
    @Binding var navToRoot: Bool
    @ObservedObject var uiImageHolder: UIImageHolder

    var albums: [String] = []

    let rows1 = [
        GridItem(.flexible(minimum: UIScreen.main.bounds.width / 1.7))
    ]
    let rows2 = [
        GridItem(.flexible(minimum: UIScreen.main.bounds.width / 1.7)),
        GridItem(.flexible(minimum: UIScreen.main.bounds.width / 1.7))
    ]

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: albums.count > 1 ? rows2 : rows1, spacing: 10) {
                        NavigationLink(destination: {
                            GallerySceneView(library: library, sortingSelector: $sortingSelector, uiImageHolder: uiImageHolder, navToRoot: $navToRoot, photosSelector: .normal)
                        }, label: {
                            UIAlbumBlockView(library: library, sortingSelector: $sortingSelector,
                                    uiImageHolder: uiImageHolder)
                        })

                    }
                }
                .padding(.horizontal, 15)

                HStack {
                    Text("Other").font(.title2).bold()
                    Spacer()
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 5)
                VStack(spacing: 10) {
                    Divider()
                    NavigationLink {
                        GallerySceneView(library: library, sortingSelector: $sortingSelector, uiImageHolder: uiImageHolder, navToRoot: $navToRoot, photosSelector: .deleted)
                    } label: {
                        HStack {
                            Label("Recently Deleted", systemImage: "trash").font(.title3)
                            Spacer()
                            Text(String(library.photos.filter({ img in
                                img.status == .deleted
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
                    Button {

                    } label: {
                        Image(systemName: "plus")
                    }

                }
            }
            .navigationTitle("Albums")
        }
    }
}

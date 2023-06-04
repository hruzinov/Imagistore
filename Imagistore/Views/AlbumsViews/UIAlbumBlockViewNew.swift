//
//  Created by Evhen Gruzinov on 03.06.2023.
//

import SwiftUI

struct UIAlbumBlockViewNew: View {
    @StateObject var library: PhotosLibrary
    var photos: FetchedResults<Photo>
    var albums: FetchedResults<Album>
    @State var currentAlbum: Album
    @Binding var sortingArgument: PhotosSortArgument
    @StateObject var imageHolder: UIImageHolder
    @Binding var navToRoot: Bool

    var filteredPhotos: [Photo] {
        sortedPhotos(photos, by: sortingArgument, filter: .normal).filter { photo in
            currentAlbum.photos.contains { phId in
                if let uuid = photo.uuid {
                    return uuid == phId
                } else {
                    return false
                }
            }
        }
    }

    var body: some View {
        NavigationLink(destination: {
            GallerySceneView(library: library, photos: photos, albums: albums, currentAlbum: currentAlbum, sortingArgument: $sortingArgument,
                             imageHolder: imageHolder, navToRoot: $navToRoot, scrollToBottom: .constant(false), photosSelector: .normal)
        }, label: {
            HStack {
                if let lastImage = filteredPhotos.last, let lastID = lastImage.uuid {
                    if let uiImage = imageHolder.data[lastID] {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width / 2.3,
                                   height: UIScreen.main.bounds.width / 2.3)
                            .clipped()
                            .aspectRatio(1, contentMode: .fit)
                            .cornerRadius(5)
                    } else {
                        ProgressView().progressViewStyle(.circular)
                            .task {
                                if let data = lastImage.miniature, let uiImage = UIImage(data: data) {
                                    imageHolder.data[lastID] = uiImage
                                    imageHolder.objectWillChange.send()
                                }
                            }
                    }
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
                        HStack {
                            Text(currentAlbum.title)
                                .padding(5)
                                .bold()
                            Spacer()
                            Text(String(filteredPhotos.count))
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

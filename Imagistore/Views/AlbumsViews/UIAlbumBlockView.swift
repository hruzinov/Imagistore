//
//  Created by Evhen Gruzinov on 03.04.2023.
//

import SwiftUI

struct UIAlbumBlockView: View {
    @StateObject var library: PhotosLibrary
    @Binding var sortingArgument: PhotosSortArgument
    @StateObject var imageHolder: UIImageHolder
    var photos: FetchedResults<Photo>
    var filteredPhotos: [Photo] {
        sortedPhotos(photos, by: sortingArgument, filter: .normal)
    }

    var body: some View {
        HStack {
            if let lastImage = filteredPhotos.last {
                if let uiImage = imageHolder.data[lastImage.uuid] {
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
                                imageHolder.data[lastImage.uuid] = uiImage
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
                        Text("All images")
                            .padding(5)
                            .bold()
                        Spacer()
                        Text(String(filteredPhotos.count))
                    }
                }
                .font(.subheadline)
                .padding(5)
            })
        .foregroundColor(Color.white)
    }
}

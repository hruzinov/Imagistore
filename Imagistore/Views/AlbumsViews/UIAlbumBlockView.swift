//
//  Created by Evhen Gruzinov on 03.04.2023.
//

import SwiftUI

struct UIAlbumBlockView: View {
    @ObservedObject var library: PhotosLibrary
    @Binding var sortingSelector: PhotosSortArgument
    @Binding var uiImageHolder: UIImageHolder
    var photos: [Photo] { library.sortedPhotos(by: sortingSelector, filter: .normal) }

    var body: some View {
        HStack {
            if photos.last != nil {
                let lastImage = photos.last!
                if let uiImage = uiImageHolder.getUiImage(lastImage, lib: library) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width / 2.3,
                               height: UIScreen.main.bounds.width / 2.3)
                        .clipped()
                        .aspectRatio(1, contentMode: .fit)
                        .cornerRadius(5)
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
                        Text(String(photos.count))
                    }
                }
                .font(.subheadline)
                .padding(5)
            })
        .foregroundColor(Color.white)
    }
}

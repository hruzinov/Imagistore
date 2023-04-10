//
//  Created by Evhen Gruzinov on 03.04.2023.
//

import SwiftUI

struct AlbumBlockView: View {
    @Binding var library: PhotosLibrary
    var allPhotos: [Photo] { library.photos.filter({ img in
        img.status == .normal
    })}
    
    var body: some View {
        VStack {
            if allPhotos.last != nil {
                let lastImage: Photo = allPhotos.last!
                if let uiImage = lastImage.uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width / 2.3,
                               height: UIScreen.main.bounds.width / 2.3)
                        .clipped()
                        .aspectRatio(1, contentMode: .fit)
                        .cornerRadius(5)
                        .overlay(
                            ZStack {
                                Text(String(library.photos.filter({ img in
                                    img.status == .normal
                                }).count))
                                .padding(5)
                                .background {
                                    Circle().fill(Color.white).opacity(0.7)
                                }
                            }.padding(3)
                        , alignment: .bottomTrailing)
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
            HStack {
                VStack(alignment: .leading) {
                    Text("All images")
                    
                }
                Spacer()
            }
        }
        .foregroundColor(.black)
    }
}

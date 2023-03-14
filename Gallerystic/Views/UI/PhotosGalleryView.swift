//
//  PhotosGalleryView.swift
//  Gallerystic
//
//  Created by Evhen Gruzinov on 14.03.2023.
//

import SwiftUI

struct PhotosGalleryView: View {
    @Binding var library: PhotosLibrary
    var photos: [Photo] {
        library.filterPhotos(status: .normal)
    }
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .center) {
                ForEach(photos) { item in
                    if let uiImage = readImageFromFile(id: item.id) {
                        GeometryReader { gr in
                            NavigationLink(destination: ImageDetailedView(selectedImage: item, library: $library), label: {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: gr.size.width)
                            })
                        }
                        .clipped()
                        .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
            Spacer()
        }
    }
}

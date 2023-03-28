//
//  Created by Evhen Gruzinov on 14.03.2023.
//

import SwiftUI

struct PhotosGalleryView: View {
    @Binding var library: PhotosLibrary
    @Binding var selectedImage: Photo?
    
    let columns = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .center, spacing: 1) {
                ForEach($library.photos) { $item in
                    if item.status == .normal {
                        if let uiImage = item.imageData {
                            GeometryReader { gr in
                                NavigationLink {
                                    ImageDetailedView(selectedImage: item.id, library: $library)
                                        .preferredColorScheme(.dark)
                                } label: {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: gr.size.width)
                                }
                            }
                            .clipped()
                            .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
            }
            Spacer()
        }
    }
}

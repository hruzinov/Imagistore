//
//  Created by Evhen Gruzinov on 14.03.2023.
//

import SwiftUI

struct PhotosGalleryView: View {
    @Binding var library: PhotosLibrary
    @State var photosSelector: PhotoStatus
    @Binding var sortingSelector: PhotosSortArgument
    @State var selectedImage: Photo?
    
    let columns = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .center, spacing: 1) {
                ForEach($library.photos
                    .sorted(by: { ph1, ph2 in
                        switch sortingSelector {
                        case .importDate:
                            return ph1.importDate.wrappedValue < ph2.importDate.wrappedValue
                        case .creationDate:
                            return ph1.creationDate.wrappedValue < ph2.creationDate.wrappedValue
                        }
                    })
                        .filter({ $ph in
                            ph.status == photosSelector
                        })) { $item in
                            if let uiImage = item.uiImage {
                                GeometryReader { gr in
                                    NavigationLink {
                                        ImageDetailedView(photosSelector: photosSelector, library: $library, sortingSelector: $sortingSelector, selectedImage: item.id)
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
    }
}

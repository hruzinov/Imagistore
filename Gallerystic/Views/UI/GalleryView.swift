//
//  Created by Evhen Gruzinov on 14.03.2023.
//

import SwiftUI

struct GalleryView: View {
    @ObservedObject var library: PhotosLibrary
    var photos: [Binding<Photo>] {
        $library.photos
            .sorted(by: { ph1, ph2 in
                if photosSelector == .deleted, let delDate1 = ph1.deletionDate.wrappedValue, let delDate2 = ph2.deletionDate.wrappedValue {
                    return delDate1 < delDate2
                } else {
                    switch sortingSelector {
                    case .importDate:
                        return ph1.importDate.wrappedValue < ph2.importDate.wrappedValue
                    case .creationDate:
                        return ph1.creationDate.wrappedValue < ph2.creationDate.wrappedValue
                    }
                }
            })
            .filter({ $ph in
                ph.status == photosSelector
            })
    }
    
    @State var photosSelector: PhotoStatus
    @Binding var sortingSelector: PhotosSortArgument
    @Binding var scrollTo: UUID?
    
    let columns = [
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1),
        GridItem(.flexible(), spacing: 1)
    ]
    
    var body: some View {
        ScrollViewReader { scroll in
            ScrollView {
                LazyVGrid(columns: columns, alignment: .center, spacing: 1) {
                    ForEach(photos) { $item in
                        if item.uiImage != nil {
                            GeometryReader { gr in
                                let size = gr.size
                                NavigationLink {
                                    ImageDetailedView(library: library, photosSelector: photosSelector, sortingSelector: $sortingSelector, selectedImage: item.id, scrollTo: $scrollTo)
                                } label: {
                                    Image(uiImage: item.uiImage!)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: size.height, height: size.width, alignment: .center)
                                        .id(item.id)
                                        .overlay(
                                            ZStack {
                                                if let deletionDate = item.deletionDate {
                                                    LinearGradient(colors: [.black.opacity(0), .black], startPoint: .center, endPoint: .bottom)
                                                    VStack(alignment: .center) {
                                                        Spacer()
                                                        Text(TimeFunctions.daysLeftString(deletionDate))
                                                            .font(.caption)
                                                            .padding(5)
                                                            .foregroundColor(TimeFunctions.daysLeft(deletionDate) < 3 ? .red : .white)
                                                    }
                                                }
                                            }
                                        )
                                }
                            }
                            .clipped()
                            .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
                Rectangle()
                    .frame(height: 50)
                    .opacity(0)
            }
            .onChange(of: scrollTo) { _ in
                if let scrollTo {
                    scroll.scrollTo(scrollTo, anchor: .leading)
                }
            }
        }
    }
}

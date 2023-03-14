//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @Binding var library: PhotosLibrary
    @State private var importSelectedItem: PhotosPickerItem? = nil
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, alignment: .center) {
                    ForEach(library.photos, id: \.self) { item in
                        if let uiImage = readImageFromFile(id: item.id) {
                            GeometryReader { gr in
                                NavigationLink(destination: ImageDetailedView(selectedImage: item, library: library), label: {
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
            .toolbar {
                PhotosPicker(
                    selection: $importSelectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) { Image(systemName: "plus") }
                    .onChange(of: importSelectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                let uiImage = UIImage(data: data)
                                if let uiImage {
                                    let uuid = writeImageToFile(uiImage: uiImage)
                                    if let uuid {
                                        library.addImages([Photo(id: uuid)])
                                    }
                                }
                            }
                        }
                    }
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(library: .constant(PhotosLibrary(photos: [Photo])))
//    }
//}

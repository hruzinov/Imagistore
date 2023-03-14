//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI

struct ImageDetailedView: View {
    @State var selectedImage: Photo
    @Binding var library: PhotosLibrary
    var photos: [Photo] {
        library.filterPhotos(status: .normal)
    }
    
    var body: some View {
        VStack {
            if let uiImage = readImageFromFile(id: selectedImage.id) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            }
            Spacer()
            ScrollView(.horizontal) {
                ScrollViewReader { scroll in
                    HStack {
                        ForEach(photos) { item in
                            if let uiImage = readImageFromFile(id: item.id) {
                                Button {
                                    self.selectedImage = item
                                } label: {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 150, height: 150)
                                        .overlay(selectedImage == item ? RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth:4) : nil)
                                        .padding(2)
                                        .id(item.id)
                                }
                            }
                        }
                    }
                    .onAppear {
                        scroll.scrollTo(selectedImage.id)
                    }
                }
            }
            HStack {
                Spacer()
                Menu {
                    Button(role: .destructive) {
                        let deletedImage = selectedImage
                        if let photoIndex = library.photos.firstIndex(of: deletedImage) {
                            
                            if photos.count > 1 {
                                if photoIndex == 0 {
                                    selectedImage = photos[photoIndex+1]
                                } else {
                                    selectedImage = photos[photoIndex-1]
                                }
                            }
                            
                            library.photos.remove(at: photoIndex)
                            
//                            library.removeImages([deletedImage])
                        }
                    } label: {
                        Text("Confirm").foregroundColor(Color.red)
                    }

                } label: {
                    Image(systemName: "trash").font(.title2)
                }
//                Button {
//                    <#code#>
//                } label: {
//                    Image(systemName: "trash")
//                }

            }
            .padding(.top, 5)
        }
    }
}

//struct ImageDetailedView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageDetailedView(selectedImage: testImagesModels[1], images: testImagesModels)
//    }
//}

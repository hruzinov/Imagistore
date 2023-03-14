//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI

struct ImageDetailedView: View {
    @State var selectedImage: Photo
    @State var library: PhotosLibrary
    
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
                        ForEach(library.photos, id: \.self) { item in
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
        }
    }
}

//struct ImageDetailedView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageDetailedView(selectedImage: testImagesModels[1], images: testImagesModels)
//    }
//}

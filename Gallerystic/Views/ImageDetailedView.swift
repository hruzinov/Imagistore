//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI

struct ImageDetailedView: View {
    @State var selectedImage: UUID
    @Binding var library: PhotosLibrary
    
    var body: some View {
        ZStack {
//            Color.black
//                .ignoresSafeArea()
            
            VStack {
                TabView(selection: $selectedImage) {
                    ForEach($library.photos) { $item in
                        if let uiImage = item.uiImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .pinchToZoom()
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//                .overlay(
//                    ScrollView(.horizontal) {
//                        ScrollViewReader { scroll in
//                            HStack {
//                                ForEach($library.photos) { $item in
//                                    if item.status == .normal {
//                                        if let uiImage = item.imageData {
//                                            Button {
//                                                self.selectedImage = item.id
//                                            } label: {
//                                                Image(uiImage: uiImage)
//                                                    .resizable()
//                                                    .scaledToFit()
//                                                    .frame(width: 80, height: 80)
//                                                    .overlay(selectedImage == item.id ? RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth:4) : nil)
//                                                    .padding(2)
//                                                    .id(item.id)
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                            .onAppear {
//                                scroll.scrollTo(selectedImage, anchor: .center)
//                            }
//                            .onChange(of: selectedImage) { newValue in
//                                withAnimation {
//                                    scroll.scrollTo(selectedImage)
//                                }
//
//                            }
//                        }
//                    }
//                    , alignment: .bottom)
                
                //                    HStack {
                //                        Spacer()
                //                        Menu {
                //                            Button(role: .destructive) {
                //                                let deletedImage = selectedImage
                //                                if let photoIndex = library.photos.firstIndex(of: deletedImage) {
                //                                    library.photos.remove(at: photoIndex)
                //                                }
                //                            } label: {
                //                                Text("Confirm").foregroundColor(Color.red)
                //                            }
                //
                //                        } label: {
                //                            Image(systemName: "trash").font(.title2)
                //                        }
                //                    }
                //                    .padding(.top, 5)
                //                    .padding(.bottom, 10)
                //                    .padding(.horizontal, 20)
            }
        }
        ScrollView(.horizontal) {
            ScrollViewReader { scroll in
                HStack {
                    ForEach($library.photos) { $item in
                        if item.status == .normal {
                            if let uiImage = item.uiImage {
                                Button {
                                    self.selectedImage = item.id
                                } label: {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 75, height: 75)
                                        .overlay(selectedImage == item.id ? RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth:3) : nil)
                                        .padding(2)
                                        .id(item.id)
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    scroll.scrollTo(selectedImage, anchor: .center)
                }
                .onChange(of: selectedImage) { newValue in
                    withAnimation {
                        scroll.scrollTo(selectedImage)
                    }
                    
                }
            }
        }
//        , alignment: .bottom)
    }
}

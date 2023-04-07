//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI

struct ImageDetailedView: View {
    @Environment(\.dismiss) var dismiss
    @State var selectedImage: UUID
    @Binding var library: PhotosLibrary
    @State var photosSelector: PhotoStatus
    @Binding var sortingSelector: PhotosSortArgument
    
    var filteredPhotos: [Photo] {
        library.photos
            .sorted(by: { ph1, ph2 in
                switch sortingSelector {
                case .importDate:
                    return ph1.importDate < ph2.importDate
                case .creationDate:
                    return ph1.creationDate < ph2.creationDate
                }
            })
            .filter { ph in
                ph.status == photosSelector
            }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    TabView(selection: $selectedImage) {
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
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .pinchToZoom()
                                    }
                                }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .toolbar(.hidden, for: .tabBar)
                }
            }
            ScrollView(.horizontal) {
                ScrollViewReader { scroll in
                    HStack {
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
                                        Button { self.selectedImage = item.id } label: {
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
                    .onAppear { scroll.scrollTo(selectedImage, anchor: .center) }
                    .onChange(of: selectedImage) { newValue in
                        withAnimation { scroll.scrollTo(selectedImage) }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                if photosSelector == .deleted {
                    Button { changePhotoStatus() } label: { Text("Recover") }
                } else {
                    Menu {
                        Button(role: .destructive) { changePhotoStatus() } label: { Text("Confirm").foregroundColor(Color.red) }
                    } label: { Image(systemName: "trash") }
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .foregroundColor(.blue)
    }
    
    private func changePhotoStatus() {
        let changedPhoto = filteredPhotos.first(where: { $0.id == selectedImage })
        if let changedPhoto, let photoIndex = filteredPhotos.firstIndex(of: changedPhoto) {
            if photosSelector == .normal { library.removeImages([changedPhoto]) }
            else { library.recoverImages([changedPhoto]) }
            
            if filteredPhotos.count == 0 { dismiss() }
            else if photoIndex == filteredPhotos.count { selectedImage = filteredPhotos[photoIndex-1].id }
            else { selectedImage = filteredPhotos[photoIndex].id }
        }
    }
}

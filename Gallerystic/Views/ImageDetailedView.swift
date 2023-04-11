//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI

struct ImageDetailedView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dispayingSettings: DispayingSettings
    
    @State var photosSelector: PhotoStatus
    @ObservedObject var library: PhotosLibrary
    @Binding var sortingSelector: PhotosSortArgument
    
    @State var selectedImage: UUID
    @State var isPresentingConfirm: Bool = false
    
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
                                if item.uiImage != nil {
                                    ZStack {
                                        
                                        Image(uiImage: item.uiImage!)
                                            .resizable()
                                            .scaledToFit()
                                            .pinchToZoom()
                                    }
                                    .frame(maxHeight: .infinity)
                                    .overlay(alignment: .bottomTrailing) {
                                        if item.fileExtention == .png {
                                            Text("PNG")
                                                .foregroundColor(.none)
                                                .padding(.horizontal, 10)
                                                .background(Color(UIColor.lightGray))
                                                .cornerRadius(10)
                                                .padding(.horizontal, 10)
                                        }
                                    }
                                }
                            }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .padding(.vertical, 10)
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
                                    if item.uiImage != nil {
                                        Button { self.selectedImage = item.id } label: {
                                            Image(uiImage: item.uiImage!)
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
            .padding(.horizontal, 10)
        }
        .confirmationDialog("Delete this photo", isPresented: $isPresentingConfirm) {
            Button("Delete photo", role: .destructive) {
                if photosSelector == .deleted {
                    changePhotoStatus(to: "permanentRemove")
                } else {
                    changePhotoStatus(to: "bin")
                }
            }
        } message: {
            if photosSelector == .deleted {
                Text("You cannot undo this action")
            }
        }
        
        .onAppear { dispayingSettings.isShowingTabBar = false }
        .onDisappear {
            withAnimation(Animation.easeInOut(duration: 0.3)) { dispayingSettings.isShowingTabBar = true }
        }
        
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                if photosSelector == .deleted {
                    Button { isPresentingConfirm.toggle() } label: { Text("Delete permanently") }
                    Button { changePhotoStatus(to: "recover") } label: { Text("Recover") }
                } else {
                    Button { isPresentingConfirm.toggle() } label: { Image(systemName: "trash") }
                }
            }
        }
        .padding(.vertical, 10)
        .foregroundColor(.blue)
    }
    
    private func changePhotoStatus(to: String) {
        let changedPhoto = filteredPhotos.first(where: { $0.id == selectedImage })
        if let changedPhoto, let photoIndex = filteredPhotos.firstIndex(of: changedPhoto) {
            if to == "bin" { library.toBin([changedPhoto]) }
            else if to == "recover" { library.recoverImages([changedPhoto]) }
            else if to == "permanentRemove" { library.permanentRemove([changedPhoto]) }
            
            if filteredPhotos.count == 0 { DispatchQueue.main.async { dismiss() }}
            else if photoIndex == filteredPhotos.count { selectedImage = filteredPhotos[photoIndex-1].id }
            else { selectedImage = filteredPhotos[photoIndex].id }
        }
    }
}

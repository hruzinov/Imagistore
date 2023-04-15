//
//  Created by Evhen Gruzinov on 12.03.2023.
//

import SwiftUI

struct ImageDetailedView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dispayingSettings: DispayingSettings
    
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
    
    @State var selectedImage: UUID
    @Binding var scrollTo: UUID?
    @State var isPresentingConfirm: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                TabView(selection: $selectedImage) {
                    ForEach(photos) { $item in
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
            
            ScrollViewReader { scroll in
                ScrollView(.horizontal) {
                    HStack(spacing: 0) {
                        ForEach(photos) { $item in
                            if item.uiImage != nil {
                                Button {
                                    self.selectedImage = item.id
                                    scrollTo = selectedImage
                                } label: {
                                    if selectedImage == item.id {
                                        Image(uiImage: item.uiImage!)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(maxWidth: .infinity, maxHeight: 75, alignment: .center)
                                            .padding(5)
                                            .border(Color.primary, width: 5)
                                            .padding(20)
                                            .clipped()
                                            .id(item.id)
                                    } else {
                                        Image(uiImage: item.uiImage!)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 75, alignment: .center)
                                            .clipped()
                                            .id(item.id)
                                    }
                                }
                            }
                        }
                    }
                    .onAppear { scroll.scrollTo(selectedImage, anchor: .center) }
                    .onChange(of: selectedImage) { _ in
                        withAnimation { scroll.scrollTo(selectedImage, anchor: .center) }
                    }
                }
            }
        }
        .confirmationDialog("Delete this photo", isPresented: $isPresentingConfirm) {
            Button("Delete photo", role: .destructive) {
                if photosSelector == .deleted {
                    changePhotoStatus(to: .permanent)
                } else {
                    changePhotoStatus(to: .bin)
                }
            }
        } message: {
            if photosSelector == .deleted {
                Text("You cannot undo this action")
            }
        }
        
        .onAppear { dispayingSettings.isShowingTabBar = false }
        .onDisappear { dispayingSettings.isShowingTabBar = true }
        
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                if photosSelector == .deleted {
                    Button { isPresentingConfirm.toggle() } label: { Text("Delete permanently") }
                    Button { changePhotoStatus(to: .recover) } label: { Text("Recover") }
                } else {
                    Button { isPresentingConfirm.toggle() } label: { Image(systemName: "trash") }
                }
            }
        }
        .padding(.vertical, 10)
        .foregroundColor(.blue)
    }
    
    private func changePhotoStatus(to: RemovingDirection) {
        var filteredPhotos: [Photo] = []
        photos.forEach { $ph in
            filteredPhotos.append(ph)
        }
        
        let changedPhoto = filteredPhotos.first(where: { $0.id == selectedImage })
        if let changedPhoto, let photoIndex = filteredPhotos.firstIndex(of: changedPhoto) {
            switch to {
            case .bin:
                library.toBin([changedPhoto]) { err in
                    if let err {
                        dispayingSettings.errorAlertData = err.localizedDescription
                        dispayingSettings.isShowingErrorAlert.toggle()
                    }
                }
            case .recover:
                library.recoverImages([changedPhoto]) { err in
                    if let err {
                        dispayingSettings.errorAlertData = err.localizedDescription
                        dispayingSettings.isShowingErrorAlert.toggle()
                    }
                }
            case .permanent:
                library.permanentRemove([changedPhoto]) { err in
                    if let err {
                        dispayingSettings.errorAlertData = err.localizedDescription
                        dispayingSettings.isShowingErrorAlert.toggle()
                    }
                }
            }
            
            filteredPhotos.remove(at: photoIndex)
            
            if filteredPhotos.count == 0 { DispatchQueue.main.async { dismiss() }}
            else if photoIndex == filteredPhotos.count { selectedImage = filteredPhotos[photoIndex-1].id }
            else { selectedImage = filteredPhotos[photoIndex].id }
        }
    }
}

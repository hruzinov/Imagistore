//
//  Created by Evhen Gruzinov on 04.06.2023.
//

import SwiftUI

struct AddToAlbumView: View {
//    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    var photos: FetchedResults<Photo>
    var albums: FetchedResults<Album>
    var miniatures: FetchedResults<Miniature>
    @EnvironmentObject var sceneSettings: SceneSettings
    @Binding var isPresentingAddToAlbum: Bool
    @Binding var selectingMode: Bool
    @Binding var selectedImagesArray: [Photo]
    var selectedImage: UUID?

    var body: some View {
        NavigationStack {
            List {
                ForEach(albums) { alb in
                    if alb.filterOptionsSet == nil {
                        Button {
                            if selectedImagesArray.count > 0 {
                                selectedImagesArray.forEach { img in
                                    if let uuid = img.uuid {
                                        var currentSet = JSONToSet(alb.photosSet)
                                        currentSet?.insert(uuid.uuidString)
                                        alb.photosSet = setToJSON(currentSet ?? Set<String>())!
                                    }
                                }
                                selectedImagesArray = []
                            } else if let selectedImage {
                                var currentSet = JSONToSet(alb.photosSet)
                                currentSet?.insert(selectedImage.uuidString)
                                alb.photosSet = setToJSON(currentSet ?? Set<String>())!
                            }
                            
                            do {
                                try viewContext.save()
                                
                                sceneSettings.isShowingTabBar = true
                                selectingMode.toggle()
                                
                                sceneSettings.isShowingInfoBar = true
                                sceneSettings.infoBarFinal = true; sceneSettings.infoBarData = "Added to album"
                                sceneSettings.infoBarProgress = 1
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    withAnimation { sceneSettings.isShowingInfoBar.toggle() }
                                }
                            } catch {
                                sceneSettings.errorAlertData = error.localizedDescription
                                sceneSettings.isShowingErrorAlert.toggle()
                            }
                            
                            isPresentingAddToAlbum.toggle()
                        } label: {
                            HStack {
                                if let lastImageId = JSONToArray(alb.photosSet)?.last {
                                    if let data = miniatures.first(where: { $0.uuid == UUID(uuidString: lastImageId)})?.miniature,
                                        let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: UIScreen.main.bounds.width / 7,
                                                   height: UIScreen.main.bounds.width / 7)
                                            .clipped()
                                            .aspectRatio(1, contentMode: .fit)
                                            .cornerRadius(5)
                                    }
                                } else {
                                    VStack {
                                        Spacer()
                                        Image(systemName: "photo.on.rectangle")
                                            .foregroundColor(.gray)
                                            .font(.title)
                                            .frame(width: UIScreen.main.bounds.width / 7,
                                                   height: UIScreen.main.bounds.width / 7)
                                        Spacer()
                                    }
                                    .cornerRadius(5)
                                }
                                
                                Text(alb.title).foregroundColor(.primary)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Add to album", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isPresentingAddToAlbum.toggle()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
        }
    }
}
